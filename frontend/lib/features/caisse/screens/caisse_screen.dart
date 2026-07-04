import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/stock/providers/stock_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/panier_item.dart';
import '../providers/caisse_provider.dart';
import '../widgets/panier_widget.dart';
import '../widgets/numpad_widget.dart';
import '../widgets/catalogue_grid.dart';

enum CaisseMode { calculatrice, catalogue }

class CaisseScreen extends ConsumerStatefulWidget {
  const CaisseScreen({super.key});

  @override
  ConsumerState<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends ConsumerState<CaisseScreen> {
  CaisseMode _mode = CaisseMode.catalogue;

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    final total = panier.fold(0.0, (sum, item) => sum + item.total);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Caisse'),
            if (user != null)
              Text(
                user.nom,
                style: AppTextStyles.caption,
              ),
          ],
        ),
        actions: [
          // Basculer mode
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeToggleBtn(
                  label: 'Catalogue',
                  icon: Symbols.grid_view,
                  selected: _mode == CaisseMode.catalogue,
                  onTap: () => setState(() => _mode = CaisseMode.catalogue),
                ),
                _ModeToggleBtn(
                  label: 'Calculatrice',
                  icon: Symbols.calculate,
                  selected: _mode == CaisseMode.calculatrice,
                  onTap: () => setState(() => _mode = CaisseMode.calculatrice),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Panier
          if (panier.isNotEmpty)
            PanierWidget(items: panier),

          // Corps (catalogue ou numpad)
          Expanded(
            child: _mode == CaisseMode.catalogue
                ? CatalogueGrid(onProduitTap: _addProduitToPanier)
                : NumpadWidget(onMontantValidé: _addMontantLibre),
          ),

          // Barre de total + action
          if (panier.isNotEmpty)
            _TotalBar(
              total: total,
              onValidate: () => _showValidationSheet(context),
              onClear: () => ref.read(panierProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  void _addProduitToPanier(LocalProduit produit) {
    ref.read(panierProvider.notifier).addProduit(produit);
  }

  void _addMontantLibre(double montant) {
    if (montant <= 0) return;
    ref.read(panierProvider.notifier).addLibre(montant);
  }

  void _showValidationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ValidationSheet(),
    );
  }
}

// ── Mode toggle bouton ────────────────────────────────────────────────────────

class _ModeToggleBtn extends StatelessWidget {
  const _ModeToggleBtn({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: selected ? Colors.white : AppColors.textSecondary),
            const HGap(4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barre total ───────────────────────────────────────────────────────────────

class _TotalBar extends StatelessWidget {
  const _TotalBar({
    required this.total,
    required this.onValidate,
    required this.onClear,
  });
  final double total;
  final VoidCallback onValidate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTextStyles.caption),
                  AmountText(
                    amount: total,
                    style: AppTextStyles.amountLarge,
                  ),
                ],
              ),
            ),
            // Effacer
            IconButton(
              icon: const Icon(Symbols.delete_sweep,
                  color: AppColors.textSecondary),
              onPressed: onClear,
              tooltip: 'Vider le panier',
            ),
            const HGap(AppSpacing.sm),
            // Valider
            SizedBox(
              width: 160,
              child: AppButton(
                label: 'Encaisser',
                onPressed: onValidate,
                icon: Symbols.payments,
                variant: AppButtonVariant.secondary,
                fullWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feuille de validation ─────────────────────────────────────────────────────

class _ValidationSheet extends ConsumerStatefulWidget {
  const _ValidationSheet();

  @override
  ConsumerState<_ValidationSheet> createState() => _ValidationSheetState();
}

class _ValidationSheetState extends ConsumerState<_ValidationSheet> {
  String _modePaiement = 'ESPECES';

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    final total = panier.fold(0.0, (sum, item) => sum + item.total);
    final isLoading = ref.watch(caisseLoadingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          ),
          const VGap(AppSpacing.xl),

          Text('Encaisser', style: AppTextStyles.headlineLarge),
          const VGap(AppSpacing.xl),

          // Total
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Column(
              children: [
                Text('Montant total',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary)),
                const VGap(AppSpacing.xs),
                AmountText(
                  amount: total,
                  style: AppTextStyles.amountHero,
                ),
              ],
            ),
          ),
          const VGap(AppSpacing.xl),

          // Mode paiement
          Text('Mode de paiement', style: AppTextStyles.labelLarge),
          const VGap(AppSpacing.md),
          Row(
            children: [
              _PaiementBtn(
                label: 'Espèces',
                icon: Symbols.payments,
                value: 'ESPECES',
                selected: _modePaiement == 'ESPECES',
                onTap: () => setState(() => _modePaiement = 'ESPECES'),
              ),
              const HGap(AppSpacing.sm),
              _PaiementBtn(
                label: 'Mobile',
                icon: Symbols.phone_iphone,
                value: 'MOBILE_MONEY',
                selected: _modePaiement == 'MOBILE_MONEY',
                onTap: () => setState(() => _modePaiement = 'MOBILE_MONEY'),
              ),
              const HGap(AppSpacing.sm),
              _PaiementBtn(
                label: 'Crédit',
                icon: Symbols.credit_card,
                value: 'CREDIT',
                selected: _modePaiement == 'CREDIT',
                onTap: () => setState(() => _modePaiement = 'CREDIT'),
              ),
            ],
          ),
          const VGap(AppSpacing.xxl),

          // Confirmer
          AppButton(
            label: 'Confirmer la vente',
            onPressed: _confirmer,
            isLoading: isLoading,
            icon: Symbols.check_circle,
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmer() async {
    final ok = await ref
        .read(caisseProvider.notifier)
        .enregistrerVente(modePaiement: _modePaiement);

    if (mounted) {
      Navigator.of(context).pop();
      if (ok) {
        AppSnackbar.success(context, 'Vente enregistrée !');
      }
    }
  }
}

class _PaiementBtn extends StatelessWidget {
  const _PaiementBtn({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? Colors.white : AppColors.textSecondary),
              const VGap(4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
