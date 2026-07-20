import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../features/abonnements/providers/quota_provider.dart';
import '../../../features/abonnements/screens/pricing_screen.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/caisse_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/tiers/providers/tiers_provider.dart';
import '../../../data/remote/tiers_api.dart';
import '../../../data/models/tier_model.dart';
import 'ticket_screen.dart';
import '../widgets/catalogue_grid.dart';
import '../../../features/stock/providers/stock_provider.dart';
import '../../../features/sessions/providers/sessions_provider.dart';
import '../models/panier_item.dart';

// ── POS Screen ────────────────────────────────────────────────────────────────

class CaisseScreen extends ConsumerStatefulWidget {
  const CaisseScreen({super.key});

  @override
  ConsumerState<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends ConsumerState<CaisseScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    final remiseGlobale = ref.watch(remiseGlobaleProvider);
    final sousTotal = panier.fold(0.0, (s, i) => s + i.total);
    final total = sousTotal * (1 - remiseGlobale / 100);
    final quotaAsync = ref.watch(quotaProvider);
    final isTablet = MediaQuery.of(context).size.width > 720;
    final sessionAsync = ref.watch(sessionNotifierProvider);
    final sessionActive = sessionAsync.valueOrNull;

    // ── Écran verrouillé si pas de session ─────────────────────────────
    if (sessionActive == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _CaisseLockScreen(sessionAsync: sessionAsync)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────────────
            _PosTopBar(
              quotaAsync: quotaAsync,
              onRefresh: _refreshData,
            ),
            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: isTablet
                  ? Row(
                      children: [
                        // Catalogue 60%
                        Expanded(
                          flex: 6,
                          child: _CataloguePane(
                            searchQuery: _searchQuery,
                            searchCtrl: _searchCtrl,
                            onSearch: (v) => setState(() => _searchQuery = v),
                            onAdd: _addProduit,
                          ),
                        ),
                        // Panier 40%
                        SizedBox(
                          width: 360,
                          child: _PanierPane(
                            panier: panier,
                            total: total,
                            onPay: () => _showPaiement(context),
                          ),
                        ),
                      ],
                    )
                  // ── Mobile : catalogue + bottom sheet panier ────────────
                  : Stack(
                      children: [
                        _CataloguePane(
                          searchQuery: _searchQuery,
                          searchCtrl: _searchCtrl,
                          onSearch: (v) => setState(() => _searchQuery = v),
                          onAdd: _addProduit,
                          bottomPadding: panier.isNotEmpty ? 80 : 0,
                        ),
                        if (panier.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _MobilePanierBar(
                              count: panier.length,
                              total: total,
                              onOpen: () => _showPanierSheet(context),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addProduit(LocalProduit p) =>
      ref.read(panierProvider.notifier).addProduit(p);

  void _refreshData() {
    ref.invalidate(stockProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(quotaProvider);
    ref.invalidate(clientsProvider);
  }

  void _showPaiement(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _PaiementDialog(),
    );
  }

  void _showPanierSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MobilePanierSheet(),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _PosTopBar extends StatelessWidget {
  const _PosTopBar({
    required this.quotaAsync,
    required this.onRefresh,
  });
  final AsyncValue quotaAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const MenuButton(),
          const SizedBox(width: 8),
          Text(
            'BabiCash POS',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Bouton refresh
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Symbols.refresh, color: Colors.white, size: 20),
            tooltip: 'Recharger les données',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Quota chip
          quotaAsync.when(
            data: (info) {
              if (info == null) return const SizedBox.shrink();
              final reste = info.ventesRestantes ?? 0;
              if (info.illimite) return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: reste <= 5
                      ? AppColors.error
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$reste ventes',
                  style: TextStyle(
                    color: reste <= 5 ? Colors.white : AppColors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Catalogue Pane ────────────────────────────────────────────────────────────

class _CataloguePane extends ConsumerWidget {
  const _CataloguePane({
    required this.searchQuery,
    required this.searchCtrl,
    required this.onSearch,
    required this.onAdd,
    this.bottomPadding = 0,
  });
  final String searchQuery;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final void Function(LocalProduit) onAdd;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Barre de recherche — juste au-dessus des filtres catégories
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: _CatalogueSearchBar(
              searchCtrl: searchCtrl,
              onSearch: onSearch,
            ),
          ),
          Expanded(
            child: CatalogueGrid(
              onProduitTap: onAdd,
              searchQuery: searchQuery,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre de recherche catalogue ──────────────────────────────────────────────

class _CatalogueSearchBar extends StatelessWidget {
  const _CatalogueSearchBar({
    required this.searchCtrl,
    required this.onSearch,
  });
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchCtrl,
      onChanged: onSearch,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Rechercher un produit...',
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        prefixIcon: const Icon(Symbols.search,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Symbols.close,
                    color: AppColors.textSecondary, size: 18),
                onPressed: () {
                  searchCtrl.clear();
                  onSearch('');
                },
                tooltip: 'Effacer la recherche',
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

// ── Panier Pane (tablet) ──────────────────────────────────────────────────────

class _PanierPane extends ConsumerStatefulWidget {
  const _PanierPane({
    required this.panier,
    required this.total,
    required this.onPay,
  });
  final List<PanierItem> panier;
  final double total;
  final VoidCallback onPay;

  @override
  ConsumerState<_PanierPane> createState() => _PanierPaneState();
}

class _PanierPaneState extends ConsumerState<_PanierPane> {
  late final TextEditingController _remiseCtrl;

  @override
  void initState() {
    super.initState();
    _remiseCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _remiseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panier = widget.panier;
    final remiseGlobale = ref.watch(remiseGlobaleProvider);
    final sousTotal = panier.fold(0.0, (s, i) => s + i.total);
    final totalFinal = sousTotal * (1 - remiseGlobale / 100);

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxFooterH = constraints.maxHeight * 0.72;
          return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(left: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header commande
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryContainer,
            child: Row(
              children: [
                const Icon(Symbols.shopping_cart,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Commande',
                  style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                // Bouton client
                _ClientBouton(panier: panier),
                if (panier.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(panierProvider.notifier).clear(),
                    icon: const Icon(Symbols.delete_sweep,
                        size: 14, color: AppColors.error),
                    label: const Text('Vider',
                        style: TextStyle(
                            color: AppColors.error, fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ],
              ],
            ),
          ),
          // Lignes panier
          Flexible(
            child: panier.isEmpty
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Symbols.shopping_cart,
                              size: 36, color: AppColors.textDisabled),
                          const SizedBox(height: 6),
                          Text('Panier vide',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary)),
                          const SizedBox(height: 2),
                          Text('Sélectionnez un produit',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textDisabled)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: panier.length,
                    itemBuilder: (_, i) =>
                        _PanierLigne(item: panier[i], index: i),
                  ),
          ),
          // Footer total + paiement
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxFooterH),
            child: SingleChildScrollView(
              child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              children: [
                // Sous-total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sous-total',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                    AmountText(
                        amount: sousTotal,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                // Remise globale
                Row(
                  children: [
                    Icon(Symbols.percent,
                        size: 14,
                        color: panier.isEmpty
                            ? AppColors.textDisabled
                            : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('Remise générale',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: panier.isEmpty
                                ? AppColors.textDisabled
                                : AppColors.textSecondary)),
                    const Spacer(),
                    SizedBox(
                      width: 70,
                      height: 28,
                      child: TextField(
                        enabled: panier.isNotEmpty,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: panier.isEmpty
                                ? AppColors.textDisabled
                                : AppColors.textPrimary),
                        controller: _remiseCtrl,
                        onChanged: (v) {
                          final val = double.tryParse(v) ?? 0.0;
                          ref
                              .read(remiseGlobaleProvider.notifier)
                              .state = val.clamp(0, 100);
                        },
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                              color: AppColors.textDisabled, fontSize: 13),
                          suffixText: '%',
                          suffixStyle: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (remiseGlobale > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Économie',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.success, fontSize: 11)),
                      Text(
                        '- ${(sousTotal - totalFinal).toStringAsFixed(0)} F',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                const Divider(color: AppColors.borderLight, height: 8),
                const SizedBox(height: 2),
                // Total final
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800)),
                    AmountText(
                      amount: totalFinal,
                      style: AppTextStyles.amountLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: panier.isEmpty ? null : widget.onPay,
                    icon: const Icon(Symbols.payments, size: 20),
                    label: const Text('Encaisser',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.borderLight,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            ),
            ),
          ),
        ],
          ),
          );
        },
      ),
    );
  }
}

// ── Ligne panier ──────────────────────────────────────────────────────────────

class _PanierLigne extends ConsumerWidget {
  const _PanierLigne({required this.item, required this.index});
  final PanierItem item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRemise = item.remise > 0;

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _LigneEditDialog(item: item, index: index),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            // Nom + sous-info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        '${item.prixUnitaire.toStringAsFixed(0)} F',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary, fontSize: 11),
                      ),
                      if (hasRemise) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${item.remise.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Contrôle quantité
            Row(
              children: [
                _QteBtn(
                  icon: Symbols.remove,
                  onTap: () => ref
                      .read(panierProvider.notifier)
                      .updateQuantite(index, item.quantite - 1),
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantite}',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
                _QteBtn(
                  icon: Symbols.add,
                  onTap: () => ref
                      .read(panierProvider.notifier)
                      .updateQuantite(index, item.quantite + 1),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Total ligne
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.total.toStringAsFixed(0)} F',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  if (hasRemise)
                    Text(
                      '${(item.prixUnitaire * item.quantite).toStringAsFixed(0)} F',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            // Supprimer
            IconButton(
              icon: const Icon(Symbols.close, size: 14, color: AppColors.error),
              onPressed: () =>
                  ref.read(panierProvider.notifier).remove(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialog édition ligne panier ───────────────────────────────────────────────

class _LigneEditDialog extends ConsumerStatefulWidget {
  const _LigneEditDialog({required this.item, required this.index});
  final PanierItem item;
  final int index;

  @override
  ConsumerState<_LigneEditDialog> createState() => _LigneEditDialogState();
}

class _LigneEditDialogState extends ConsumerState<_LigneEditDialog> {
  late final TextEditingController _qteCtrl;
  late final TextEditingController _remiseCtrl;
  late final TextEditingController _prixCtrl;

  @override
  void initState() {
    super.initState();
    _qteCtrl =
        TextEditingController(text: widget.item.quantite.toString());
    _remiseCtrl = TextEditingController(
        text: widget.item.remise > 0
            ? widget.item.remise.toStringAsFixed(0)
            : '');
    _prixCtrl = TextEditingController(
        text: widget.item.prixUnitaire.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    _remiseCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(widget.item.nom,
                      style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700),
                      maxLines: 2),
                ),
                IconButton(
                  icon: const Icon(Symbols.close,
                      color: AppColors.textSecondary, size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(color: AppColors.borderLight, height: 20),

            // Quantité
            _EditField(
              label: 'Quantité',
              controller: _qteCtrl,
              suffix: 'unité(s)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Prix unitaire
            _EditField(
              label: 'Prix unitaire',
              controller: _prixCtrl,
              suffix: 'FCFA',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),

            // Remise
            _EditField(
              label: 'Remise',
              controller: _remiseCtrl,
              suffix: '%',
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Bouton appliquer
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _appliquer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Appliquer',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _appliquer() {
    final qte = int.tryParse(_qteCtrl.text) ?? widget.item.quantite;
    final prix =
        double.tryParse(_prixCtrl.text) ?? widget.item.prixUnitaire;
    final remise = double.tryParse(_remiseCtrl.text) ?? 0.0;
    final notifier = ref.read(panierProvider.notifier);
    notifier.updateQuantite(widget.index, qte);
    notifier.updatePrix(widget.index, prix);
    notifier.updateRemise(widget.index, remise);
    Navigator.pop(context);
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    required this.suffix,
    this.hint,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final String suffix;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textDisabled),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _QteBtn extends StatelessWidget {
  const _QteBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}

// ── Mobile : barre panier en bas ──────────────────────────────────────────────

class _MobilePanierBar extends StatelessWidget {
  const _MobilePanierBar({
    required this.count,
    required this.total,
    required this.onOpen,
  });
  final int count;
  final double total;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count article${count > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            const Spacer(),
            AmountText(
              amount: total,
              style: AppTextStyles.amountLarge
                  .copyWith(color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Icon(Symbols.keyboard_arrow_up, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Mobile : bottom sheet panier ──────────────────────────────────────────────

class _MobilePanierSheet extends ConsumerWidget {
  const _MobilePanierSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Réactif : la sheet suit le panier en temps réel (décrément, suppression
    // de ligne...) au lieu d'afficher une copie figée à l'ouverture.
    final panier = ref.watch(panierProvider);
    final remiseGlobale = ref.watch(remiseGlobaleProvider);
    final sousTotal = panier.fold(0.0, (s, i) => s + i.total);
    final total = sousTotal * (1 - remiseGlobale / 100);

    // Fermer la sheet si le panier se vide (dernière ligne supprimée).
    ref.listen(panierProvider, (_, next) {
      if (next.isEmpty && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Commande',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                // Bouton client — accessible aussi en portrait (petit écran)
                _ClientBouton(panier: panier),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    ref.read(panierProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Vider',
                      style: TextStyle(
                          color: AppColors.error, fontSize: 13)),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: panier.length,
              itemBuilder: (_, i) =>
                  _PanierLigne(item: panier[i], index: i),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL',
                        style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800)),
                    AmountText(
                        amount: total,
                        style: AppTextStyles.amountLarge
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const _PaiementDialog(),
                      );
                    },
                    icon: const Icon(Symbols.payments, size: 20),
                    label: const Text('Encaisser',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dialog Paiement style Odoo ────────────────────────────────────────────────

class _PaiementDialog extends ConsumerStatefulWidget {
  const _PaiementDialog();

  @override
  ConsumerState<_PaiementDialog> createState() => _PaiementDialogState();
}

class _PaiementDialogState extends ConsumerState<_PaiementDialog> {
  // Modes actifs (un seul sauf combinaison Espèces+Mobile)
  final Set<String> _modes = {'ESPECES'};
  final _montantEspecesCtrl = TextEditingController();
  final _montantMobileCtrl = TextEditingController();
  // Gardé pour compatibilité avec _confirmer
  final _montantCtrl = TextEditingController();

  String get _modePaiement {
    if (_modes.contains('CREDIT')) return 'CREDIT';
    if (_modes.contains('ESPECES') && _modes.contains('MOBILE_MONEY')) return 'ESPECES'; // mixte → on envoie ESPECES
    if (_modes.contains('MOBILE_MONEY')) return 'MOBILE_MONEY';
    return 'ESPECES';
  }

  void _toggleMode(String mode) {
    setState(() {
      if (mode == 'CREDIT') {
        _modes.clear();
        _modes.add('CREDIT');
      } else if (_modes.contains('CREDIT')) {
        _modes.clear();
        _modes.add(mode);
      } else if (_modes.contains(mode)) {
        if (_modes.length > 1) _modes.remove(mode);
      } else {
        if (mode == 'ESPECES' || mode == 'MOBILE_MONEY') {
          _modes.remove('CREDIT');
          _modes.add(mode);
        }
      }
    });
  }

  @override
  void dispose() {
    _montantEspecesCtrl.dispose();
    _montantMobileCtrl.dispose();
    _montantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    final remiseGlobale = ref.watch(remiseGlobaleProvider);
    final client = ref.watch(clientSelectionneProvider);
    final sousTotal = panier.fold(0.0, (sum, item) => sum + item.total);
    final total = sousTotal * (1 - remiseGlobale / 100);
    final isLoading = ref.watch(caisseLoadingProvider);

    final isCredit = _modes.contains('CREDIT');
    final isMulti = _modes.contains('ESPECES') && _modes.contains('MOBILE_MONEY');

    // Calcul montant reçu et monnaie
    final mEspeces = double.tryParse(_montantEspecesCtrl.text) ?? 0.0;
    final mMobile = double.tryParse(_montantMobileCtrl.text) ?? 0.0;
    final montantSaisi = isMulti
        ? mEspeces + mMobile
        : _modes.contains('ESPECES')
            ? mEspeces
            : _modes.contains('MOBILE_MONEY')
                ? mMobile
                : 0.0;
    final monnaie = montantSaisi > total ? montantSaisi - total : 0.0;

    // Validation crédit
    final creditSansClient = isCredit && client == null;
    final canConfirm = !isLoading && !creditSansClient;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Symbols.payments, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('Encaisser',
                      style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text('Montant total',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    AmountText(
                      amount: total,
                      style: AppTextStyles.amountHero
                          .copyWith(color: AppColors.primary),
                    ),
                    if (client != null) ...[const SizedBox(height: 4),
                      Text('Client : ${client.nom}',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600))],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Modes de paiement
              Text('Mode de paiement',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              if (isMulti)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Combinaison Espèces + Mobile Money',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ModeBtn(
                    label: 'Espèces',
                    icon: Symbols.payments,
                    selected: _modes.contains('ESPECES'),
                    onTap: () => _toggleMode('ESPECES'),
                  ),
                  const SizedBox(width: 8),
                  _ModeBtn(
                    label: 'Mobile Money',
                    icon: Symbols.phone_iphone,
                    selected: _modes.contains('MOBILE_MONEY'),
                    onTap: () => _toggleMode('MOBILE_MONEY'),
                  ),
                  const SizedBox(width: 8),
                  _ModeBtn(
                    label: 'Crédit',
                    icon: Symbols.credit_card,
                    selected: _modes.contains('CREDIT'),
                    onTap: () => _toggleMode('CREDIT'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Alerte crédit sans client
              if (creditSansClient) ...[const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.warning,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sélectionnez un client pour une vente à crédit.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Saisie montant Espèces
              if (_modes.contains('ESPECES') && !isCredit) ...[
                Text(isMulti ? 'Montant en espèces' : 'Montant reçu',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                _MontantField(
                  controller: _montantEspecesCtrl,
                  hint: isMulti ? '0' : total.toStringAsFixed(0),
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
              ],

              // Saisie montant Mobile Money
              if (_modes.contains('MOBILE_MONEY') && !isCredit) ...[
                Text(isMulti ? 'Montant Mobile Money' : 'Montant reçu',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                _MontantField(
                  controller: _montantMobileCtrl,
                  hint: isMulti ? '0' : total.toStringAsFixed(0),
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
              ],

              // Résumé multi-paiement
              if (isMulti && (mEspeces > 0 || mMobile > 0)) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (mEspeces > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Espèces',
                                style: AppTextStyles.bodySmall),
                            Text('${mEspeces.toStringAsFixed(0)} F',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      if (mMobile > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mobile Money',
                                style: AppTextStyles.bodySmall),
                            Text('${mMobile.toStringAsFixed(0)} F',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      const Divider(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total reçu',
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700)),
                          Text('${montantSaisi.toStringAsFixed(0)} F',
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Monnaie à rendre
              if (monnaie > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monnaie à rendre',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.success)),
                      Text(
                        '${monnaie.toStringAsFixed(0)} F',
                        style: AppTextStyles.amountLarge
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 8),
              // Bouton confirmer
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: canConfirm ? _confirmer : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.brown))
                      : const Icon(Symbols.check_circle, size: 20),
                  label: Text(
                    isLoading ? 'Enregistrement...' : 'Confirmer la vente',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.brown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmer() async {
    final panier = ref.read(panierProvider);
    final remiseGlobale = ref.read(remiseGlobaleProvider);
    final client = ref.read(clientSelectionneProvider);
    final sousTotal = panier.fold(0.0, (s, i) => s + i.total);
    final total = sousTotal * (1 - remiseGlobale / 100);
    final mEspeces = double.tryParse(_montantEspecesCtrl.text) ?? 0.0;
    final mMobile = double.tryParse(_montantMobileCtrl.text) ?? 0.0;
    final isMulti = _modes.contains('ESPECES') && _modes.contains('MOBILE_MONEY');
    final montantRecu = isMulti
        ? mEspeces + mMobile
        : _modes.contains('ESPECES') ? mEspeces : _modes.contains('MOBILE_MONEY') ? mMobile : 0.0;
    final monnaie = montantRecu > total ? montantRecu - total : 0.0;

    final caissierNom = ref.read(authStateProvider).value?.nom;
    final vente = VenteResume(
      lignes: List.from(panier),
      sousTotal: sousTotal,
      remiseGlobale: remiseGlobale,
      total: total,
      modePaiement: _modePaiement,
      montantRecu: montantRecu,
      monnaie: monnaie,
      date: DateTime.now(),
      clientNom: client?.nom,
      caissierNom: caissierNom,
    );

    final nav = Navigator.of(context);
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final ok = await ref
          .read(caisseProvider.notifier)
          .enregistrerVente(modePaiement: _modePaiement);
      if (context.mounted) {
        nav.pop();
        if (ok) {
          showDialog(
            context: rootCtx,
            builder: (_) => TicketDialog(vente: vente),
          );
        }
      }
    } on QuotaException catch (e) {
      if (context.mounted) {
        nav.pop();
        showDialog(
          context: rootCtx,
          builder: (_) => _QuotaDepasseDialog(
            ventesUtilisees: e.ventesUtilisees,
            quota: e.quota,
          ),
        );
      }
    } catch (e) {
      if (context.mounted && e.toString().contains('SESSION_REQUISE')) {
        nav.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ouvrez une session de caisse avant de vendre.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _MontantField extends StatelessWidget {
  const _MontantField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700),
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixText: 'FCFA',
        suffixStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouton client dans le header panier ───────────────────────────────────────

class _ClientBouton extends ConsumerWidget {
  const _ClientBouton({required this.panier});
  final List<PanierItem> panier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientSelectionneProvider);

    return TextButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const _ClientPickerDialog(),
      ),
      icon: Icon(
        client != null ? Symbols.person : Symbols.person_add,
        size: 14,
        color: client != null ? AppColors.primary : AppColors.textSecondary,
      ),
      label: Text(
        client != null ? client.nom : 'Client',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: client != null ? AppColors.primary : AppColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: client != null
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

// ── Dialog sélection client ───────────────────────────────────────────────────

class _ClientPickerDialog extends ConsumerStatefulWidget {
  const _ClientPickerDialog();

  @override
  ConsumerState<_ClientPickerDialog> createState() => _ClientPickerDialogState();
}

class _ClientPickerDialogState extends ConsumerState<_ClientPickerDialog> {
  final _searchCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _query = '';
  bool _showCreer = false;
  bool _creating = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _creerClient(String boutiqueId) async {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) return;
    setState(() => _creating = true);
    try {
      final api = ref.read(tiersApiProvider);
      final tier = await api.createTier(TierCreateRequest(
        boutiqueId: boutiqueId,
        nom: nom,
        telephone: _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
        typeTiers: 'CLIENT',
      ));
      // Persister dans la DB locale
      final db = ref.read(appDatabaseProvider);
      await db.upsertTier(LocalTiersCompanion(
        id: drift.Value(tier.id),
        boutiqueId: drift.Value(tier.boutiqueId),
        nom: drift.Value(tier.nom),
        telephone: drift.Value(tier.telephone),
        typeTiers: drift.Value(tier.typeTiers),
        soldeDu: drift.Value(tier.soldeDu),
        synced: const drift.Value(true),
      ));
      // Invalider le cache clients pour rafraîchir la liste
      ref.invalidate(clientsProvider);
      // Sélectionner immédiatement
      final local = LocalTier(
        id: tier.id,
        boutiqueId: tier.boutiqueId,
        nom: tier.nom,
        telephone: tier.telephone,
        typeTiers: tier.typeTiers,
        soldeDu: tier.soldeDu,
        synced: true,
      );
      ref.read(clientSelectionneProvider.notifier).state = local;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('409')
            ? 'Ce numéro de téléphone est déjà utilisé.'
            : 'Erreur lors de la création du client';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _creating = false);
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final selected = ref.watch(clientSelectionneProvider);
    final boutiqueIdAsync = ref.watch(currentBoutiqueIdProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.person_search, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _showCreer ? 'Nouveau client' : 'Sélectionner un client',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (_showCreer)
                    IconButton(
                      icon: const Icon(Symbols.arrow_back, color: Colors.white, size: 16),
                      onPressed: () => setState(() => _showCreer = false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Retour',
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Symbols.close, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            if (_showCreer) ...[
              // ── Formulaire création rapide ─────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nomCtrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Nom du client *',
                          prefixIcon: const Icon(Symbols.person, size: 18),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone (optionnel)',
                          prefixIcon: const Icon(Symbols.phone, size: 18),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _creating
                              ? null
                              : () {
                                  final boutiqueId = boutiqueIdAsync.value;
                                  if (boutiqueId != null) _creerClient(boutiqueId);
                                },
                          icon: _creating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Symbols.person_add, size: 16),
                          label: Text(_creating ? 'Création...' : 'Créer et sélectionner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── Recherche + liste ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Nom ou numéro de téléphone...',
                    prefixIcon: const Icon(Symbols.search, size: 18),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Symbols.close, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ),
              // Option : aucun client
              ListTile(
                dense: true,
                leading: const Icon(Symbols.person_off,
                    size: 18, color: AppColors.textSecondary),
                title: Text('Aucun client (vente directe)',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                trailing: selected == null
                    ? const Icon(Symbols.check_circle,
                        color: AppColors.primary, size: 16)
                    : null,
                onTap: () {
                  ref.read(clientSelectionneProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              // Liste clients filtrée
              Flexible(
                child: clientsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                      child: Text('Erreur de chargement',
                          style: AppTextStyles.bodySmall)),
                  data: (clients) {
                    final filtered = _query.isEmpty
                        ? clients
                        : clients
                            .where((c) =>
                                c.nom.toLowerCase().contains(_query) ||
                                (c.telephone ?? '').contains(_query))
                            .toList();

                    return ListView(
                      shrinkWrap: true,
                      children: [
                        // Résultats
                        ...filtered.map((c) {
                          final isSelected = selected?.id == c.id;
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                c.nom.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary),
                              ),
                            ),
                            title: Text(c.nom,
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            subtitle: c.telephone != null
                                ? Text(c.telephone!,
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary))
                                : null,
                            trailing: isSelected
                                ? const Icon(Symbols.check_circle,
                                    color: AppColors.primary, size: 16)
                                : null,
                            onTap: () {
                              ref
                                  .read(clientSelectionneProvider.notifier)
                                  .state = c;
                              Navigator.pop(context);
                            },
                          );
                        }),
                        // Bouton créer (toujours visible, plus proéminent si aucun résultat)
                        const Divider(height: 1, color: AppColors.borderLight),
                        ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.2),
                            child: const Icon(Symbols.person_add,
                                size: 14, color: AppColors.accentDark),
                          ),
                          title: Text(
                            _query.isNotEmpty && filtered.isEmpty
                                ? 'Créer "${_searchCtrl.text.trim()}"'
                                : 'Nouveau client',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            if (_query.isNotEmpty && filtered.isEmpty) {
                              // Pré-remplir le nom avec la recherche
                              _nomCtrl.text = _searchCtrl.text.trim();
                            }
                            setState(() => _showCreer = true);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Dialog quota dépassé ──────────────────────────────────────────────────────

class _QuotaDepasseDialog extends StatelessWidget {
  const _QuotaDepasseDialog({required this.ventesUtilisees, required this.quota});
  final int ventesUtilisees;
  final int quota;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Symbols.lock, size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Quota mensuel atteint',
              style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Vous avez utilisé $ventesUtilisees/$quota ventes ce mois.\nPassez à un plan payant pour continuer.',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 8),
            Text(
              'Consultez nos offres pour débloquer des ventes illimitées.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // CTA → écran pricing
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PricingScreen(),
                    ),
                  );
                },
                icon: const Icon(Symbols.rocket_launch, size: 20),
                label: const Text('Voir les plans'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Pas maintenant',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Écran de verrouillage caisse ───────────────────────────────────────────

class _CaisseLockScreen extends ConsumerStatefulWidget {
  const _CaisseLockScreen({required this.sessionAsync});
  final AsyncValue<LocalSession?> sessionAsync;

  @override
  ConsumerState<_CaisseLockScreen> createState() => _CaisseLockScreenState();
}

class _CaisseLockScreenState extends ConsumerState<_CaisseLockScreen> {
  final _fondCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fondCtrl.dispose();
    super.dispose();
  }

  Future<void> _ouvrirSession() async {
    final montant = double.tryParse(_fondCtrl.text) ?? 0;
    setState(() => _loading = true);
    try {
      final ok = await ref
          .read(sessionNotifierProvider.notifier)
          .ouvrir(montant);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la session.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.sessionAsync.isLoading;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône cadenas
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Symbols.lock,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Caisse verrouillée',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ouvrez une session pour commencer à vendre.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              // Champ fond de caisse
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  controller: _fondCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fond de caisse (FCFA)',
                    hintText: '0',
                    prefixIcon: const Icon(Symbols.payments),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton ouvrir
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _ouvrirSession,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Symbols.lock_open, size: 20),
                  label: Text(
                    _loading ? 'Ouverture...' : 'Ouvrir la session',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
