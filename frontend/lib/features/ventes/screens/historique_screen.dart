import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/vente_model.dart';
import '../../../data/remote/ventes_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/caisse/models/panier_item.dart';
import '../../../features/caisse/screens/ticket_screen.dart';
import '../../../features/settings/models/receipt_config.dart';
import '../../../features/settings/providers/receipt_config_provider.dart';
import '../../../shared/images/media_url.dart';
import '../../../shared/widgets/amount_text.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

class _FiltresVentes {
  const _FiltresVentes({
    this.modePaiement,
    this.dateDebut,
    this.dateFin,
    this.search,
    this.signaleSeulement = false,
    this.caissierId,
    this.caissierNom,
    this.includeRetours = false,
  });
  final String? modePaiement;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? search;
  final bool signaleSeulement;
  final String? caissierId;
  final String? caissierNom;
  final bool includeRetours;

  _FiltresVentes copyWith({
    Object? modePaiement = _sentinel,
    Object? dateDebut = _sentinel,
    Object? dateFin = _sentinel,
    Object? search = _sentinel,
    bool? signaleSeulement,
    Object? caissierId = _sentinel,
    Object? caissierNom = _sentinel,
    bool? includeRetours,
  }) =>
      _FiltresVentes(
        modePaiement: modePaiement == _sentinel ? this.modePaiement : modePaiement as String?,
        dateDebut: dateDebut == _sentinel ? this.dateDebut : dateDebut as DateTime?,
        dateFin: dateFin == _sentinel ? this.dateFin : dateFin as DateTime?,
        search: search == _sentinel ? this.search : search as String?,
        signaleSeulement: signaleSeulement ?? this.signaleSeulement,
        caissierId: caissierId == _sentinel ? this.caissierId : caissierId as String?,
        caissierNom: caissierNom == _sentinel ? this.caissierNom : caissierNom as String?,
        includeRetours: includeRetours ?? this.includeRetours,
      );

  static const _sentinel = Object();
}

final _filtresProvider = StateProvider<_FiltresVentes>((_) => const _FiltresVentes());

final _ventesProvider = FutureProvider.autoDispose<VenteListResponse>((ref) async {
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return const VenteListResponse(total: 0, ventes: []);
  final filtres = ref.watch(_filtresProvider);
  final api = ref.watch(ventesApiProvider);
  return api.listVentes(
    boutiqueId: boutiqueId,
    modePaiement: filtres.modePaiement,
    dateDebut: filtres.dateDebut,
    dateFin: filtres.dateFin,
    search: filtres.search,
    signaleSeulement: filtres.signaleSeulement,
    caissierId: filtres.caissierId,
    includeRetours: filtres.includeRetours,
    limit: 100,
  );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen> {
  final _searchCtrl = TextEditingController();
  final _fmt = DateFormat('dd/MM/yy HH:mm');
  final _fmtDate = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirVendeur(BuildContext context, _FiltresVentes filtres) async {
    final ventes = ref.read(_ventesProvider).value?.ventes ?? [];
    final vendeurs = <String, String>{};
    for (final v in ventes) {
      if (v.caissierId != null && v.caissierNom != null) {
        vendeurs[v.caissierId!] = v.caissierNom!;
      }
    }
    if (vendeurs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun vendeur trouvé dans les ventes affichées')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Filtrer par vendeur'),
        children: [
          for (final entry in vendeurs.entries)
            SimpleDialogOption(
              onPressed: () {
                ref.read(_filtresProvider.notifier).state = filtres.copyWith(
                  caissierId: entry.key,
                  caissierNom: entry.value,
                );
                Navigator.of(ctx).pop();
              },
              child: Row(
                children: [
                  const Icon(Symbols.person, size: 16),
                  const SizedBox(width: 8),
                  Text(entry.value),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtres = ref.watch(_filtresProvider);
    final ventesAsync = ref.watch(_ventesProvider);
    final hasFiltre = filtres.modePaiement != null ||
        filtres.dateDebut != null ||
        filtres.dateFin != null ||
        (filtres.search?.isNotEmpty ?? false) ||
        filtres.signaleSeulement ||
        filtres.caissierId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Historique des ventes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: false,
        actions: [
          if (hasFiltre)
            TextButton.icon(
              onPressed: () {
                _searchCtrl.clear();
                ref.read(_filtresProvider.notifier).state = const _FiltresVentes();
              },
              icon: const Icon(Symbols.filter_list_off, color: Colors.white, size: 18),
              label: const Text('Réinitialiser',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de recherche + filtres ────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                // Recherche
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(_filtresProvider.notifier).state =
                      filtres.copyWith(search: v.isEmpty ? null : v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom client...',
                    prefixIcon: const Icon(Symbols.search, size: 18),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Symbols.close, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(_filtresProvider.notifier).state =
                                  filtres.copyWith(search: null);
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
                const SizedBox(height: 8),
                // Chips filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltreChip(
                        label: 'Espèces',
                        icon: Symbols.payments,
                        selected: filtres.modePaiement == 'ESPECES',
                        onTap: () => ref.read(_filtresProvider.notifier).state =
                            filtres.copyWith(
                                modePaiement: filtres.modePaiement == 'ESPECES'
                                    ? null
                                    : 'ESPECES'),
                      ),
                      const SizedBox(width: 6),
                      _FiltreChip(
                        label: 'Mobile',
                        icon: Symbols.phone_android,
                        selected: filtres.modePaiement == 'MOBILE_MONEY',
                        onTap: () => ref.read(_filtresProvider.notifier).state =
                            filtres.copyWith(
                                modePaiement:
                                    filtres.modePaiement == 'MOBILE_MONEY'
                                        ? null
                                        : 'MOBILE_MONEY'),
                      ),
                      const SizedBox(width: 6),
                      _FiltreChip(
                        label: 'Crédit',
                        icon: Symbols.credit_card,
                        selected: filtres.modePaiement == 'CREDIT',
                        onTap: () => ref.read(_filtresProvider.notifier).state =
                            filtres.copyWith(
                                modePaiement: filtres.modePaiement == 'CREDIT'
                                    ? null
                                    : 'CREDIT'),
                      ),
                      const SizedBox(width: 6),
                      _FiltreChip(
                        label: 'Vente à perte',
                        icon: Symbols.trending_down,
                        selected: filtres.signaleSeulement,
                        color: AppColors.error,
                        onTap: () => ref.read(_filtresProvider.notifier).state =
                            filtres.copyWith(
                                signaleSeulement: !filtres.signaleSeulement),
                      ),
                      const SizedBox(width: 6),
                      _FiltreChip(
                        label: 'Retours',
                        icon: Symbols.undo,
                        selected: filtres.includeRetours,
                        color: Colors.deepOrange,
                        onTap: () => ref.read(_filtresProvider.notifier).state =
                            filtres.copyWith(includeRetours: !filtres.includeRetours),
                      ),
                      const SizedBox(width: 6),
                      _FiltreChip(
                        label: filtres.caissierNom != null
                            ? 'Vendeur: ${filtres.caissierNom}'
                            : 'Vendeur',
                        icon: Symbols.person,
                        selected: filtres.caissierId != null,
                        onTap: () => _choisirVendeur(context, filtres),
                        onClear: filtres.caissierId != null
                            ? () => ref.read(_filtresProvider.notifier).state =
                                filtres.copyWith(caissierId: null, caissierNom: null)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _DateChip(
                        label: filtres.dateDebut != null
                            ? 'Du ${_fmtDate.format(filtres.dateDebut!)}'
                            : 'Date début',
                        selected: filtres.dateDebut != null,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: filtres.dateDebut ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            ref.read(_filtresProvider.notifier).state =
                                filtres.copyWith(dateDebut: d);
                          }
                        },
                        onClear: filtres.dateDebut != null
                            ? () => ref.read(_filtresProvider.notifier).state =
                                filtres.copyWith(dateDebut: null)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _DateChip(
                        label: filtres.dateFin != null
                            ? 'Au ${_fmtDate.format(filtres.dateFin!)}'
                            : 'Date fin',
                        selected: filtres.dateFin != null,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: filtres.dateFin ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            ref.read(_filtresProvider.notifier).state =
                                filtres.copyWith(dateFin: d);
                          }
                        },
                        onClear: filtres.dateFin != null
                            ? () => ref.read(_filtresProvider.notifier).state =
                                filtres.copyWith(dateFin: null)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Liste ────────────────────────────────────────────────────────
          Expanded(
            child: ventesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.error_outline,
                        size: 48, color: AppColors.textDisabled),
                    const SizedBox(height: 8),
                    Text('Erreur de chargement',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(_ventesProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (resp) {
                if (resp.ventes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.receipt_long,
                            size: 56, color: AppColors.textDisabled),
                        const SizedBox(height: 12),
                        Text('Aucune vente trouvée',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          Text(
                            '${resp.total} vente${resp.total > 1 ? 's' : ''}',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            'Total : ',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          AmountText(
                            amount: resp.ventes.fold(0.0, (s, v) => s + v.montantTotal),
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => ref.invalidate(_ventesProvider),
                        child: ListView.separated(
                          itemCount: resp.ventes.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 16),
                          itemBuilder: (ctx, i) =>
                              _VenteTile(vente: resp.ventes[i], fmt: _fmt),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tuile vente ───────────────────────────────────────────────────────────────

class _VenteTile extends ConsumerStatefulWidget {
  const _VenteTile({required this.vente, required this.fmt});
  final VenteHistorique vente;
  final DateFormat fmt;

  @override
  ConsumerState<_VenteTile> createState() => _VenteTileState();
}

class _VenteTileState extends ConsumerState<_VenteTile> {
  bool _loadingRetour = false;

  VenteHistorique get vente => widget.vente;
  DateFormat get fmt => widget.fmt;

  VenteResume _toResume() {
    final lignes = vente.lignes.map((l) => PanierItem(
      produitId: l.produitId,
      nom: l.produitNom ?? 'Article libre',
      prixUnitaire: l.prixVenduReel,
      prixAchat: 0,
      quantite: l.quantite,
      remise: 0,
    )).toList();

    // Applique la personnalisation du reçu (infos boutique, en-tête, pied de
    // page, options), avec repli sur les infos de la boutique active.
    final recu =
        ref.read(receiptConfigProvider).valueOrNull ?? const ReceiptConfig();
    final boutique = ref.read(boutiqueInfoProvider).valueOrNull;
    final logoAbs =
        absoluteMediaUrl(ref.read(apiOriginProvider), boutique?.logoUrl);
    String? orBoutique(String saisi, String? boutiqueVal) {
      final v = saisi.trim();
      if (v.isNotEmpty) return v;
      final b = boutiqueVal?.trim();
      return (b != null && b.isNotEmpty) ? b : null;
    }

    return VenteResume(
      lignes: lignes,
      sousTotal: vente.montantTotal,
      remiseGlobale: 0,
      total: vente.montantTotal,
      modePaiement: vente.modePaiement,
      montantRecu: 0,
      monnaie: 0,
      date: vente.dateVente,
      nomBoutique: orBoutique(recu.nomBoutique, boutique?.nom) ?? 'BabiCash',
      adresse: orBoutique(recu.adresse, boutique?.adresse),
      telephone: orBoutique(recu.telephone, boutique?.telephone),
      entete: recu.entete,
      piedMessage: recu.piedMessage,
      afficherLogo: recu.afficherLogo,
      logoUrl: logoAbs.isEmpty ? null : logoAbs,
      clientNom: vente.clientNom,
      caissierNom: recu.afficherVendeur ? vente.caissierNom : null,
    );
  }

  Future<void> _reimprimer(BuildContext ctx) async {
    final resume = _toResume();
    showDialog(
      context: ctx,
      builder: (_) => TicketDialog(vente: resume),
    );
  }

  Future<void> _imprimerRetour(BuildContext ctx) async {
    final resume = _toResume();
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    final dateLabel = vente.dateRetour != null
        ? fmtDate.format(vente.dateRetour!.toLocal())
        : fmtDate.format(DateTime.now());
    showDialog(
      context: ctx,
      builder: (dialogCtx) => RetourReceiptDialog(
        resume: resume,
        dateRetour: dateLabel,
      ),
    );
  }

  Future<void> _confirmerRetour(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Retour marchandise'),
        content: Text(
          'Annuler cette vente de ${vente.montantTotal.toStringAsFixed(0)} F ?\n'
          'Le stock des produits sera remis à jour.'
          '${vente.modePaiement == "CREDIT" ? "\nLe solde client sera aussi ajusté." : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirmer le retour',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loadingRetour = true);
    try {
      final api = ref.read(ventesApiProvider);
      await api.retourMarchandise(vente.id);
      ref.invalidate(_ventesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Retour effectué. Stock remis à jour.'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors du retour'),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _loadingRetour = false);
  }

  Color get _modeColor {
    switch (vente.modePaiement) {
      case 'CREDIT':
        return Colors.orange;
      case 'MOBILE_MONEY':
        return Colors.blue;
      default:
        return AppColors.success;
    }
  }

  String get _modeLabel {
    switch (vente.modePaiement) {
      case 'CREDIT':
        return 'Crédit';
      case 'MOBILE_MONEY':
        return 'Mobile';
      default:
        return 'Espèces';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pré-charge la personnalisation du reçu (lue dans _toResume).
    ref.watch(receiptConfigProvider);
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: vente.statut == 'RETOURNEE'
              ? Colors.deepOrange.withValues(alpha: 0.1)
              : vente.signaleProprietaire
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          vente.statut == 'RETOURNEE'
              ? Symbols.undo
              : vente.signaleProprietaire
                  ? Symbols.warning
                  : Symbols.receipt_long,
          size: 20,
          color: vente.statut == 'RETOURNEE'
              ? Colors.deepOrange
              : vente.signaleProprietaire
                  ? AppColors.error
                  : AppColors.primary,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              vente.clientNom ?? 'Vente directe',
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (vente.statut == 'RETOURNEE')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Retourné',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _modeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _modeLabel,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _modeColor),
              ),
            ),
        ],
      ),
      subtitle: Text(
        vente.caissierNom != null
            ? '${fmt.format(vente.dateVente.toLocal())} · ${vente.caissierNom}'
            : fmt.format(vente.dateVente.toLocal()),
        style:
            AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
      ),
      trailing: vente.statut == 'RETOURNEE'
          ? Text(
              '-${vente.montantTotal.toStringAsFixed(0)} F',
              style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.deepOrange),
            )
          : AmountText(
              amount: vente.montantTotal,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
      children: [
        ...vente.lignes.map((l) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  l.venteAPerte ? Symbols.trending_down : Symbols.circle,
                  size: 10,
                  color: l.venteAPerte ? AppColors.error : AppColors.textDisabled,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l.produitNom ?? "Article libre"} × ${l.quantite}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
                AmountText(
                  amount: l.prixVenduReel * l.quantite,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        }),
        // ── Boutons d'action ─────────────────────────────────────────
        const SizedBox(height: 8),
        if (vente.statut == 'RETOURNEE') ...
          [
            if (vente.dateRetour != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Retourné le ${DateFormat('dd/MM/yyyy HH:mm').format(vente.dateRetour!.toLocal())}',
                  style: AppTextStyles.caption.copyWith(color: Colors.deepOrange),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _imprimerRetour(context),
                icon: const Icon(Symbols.print, size: 16),
                label: const Text('Reçu de retour', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  side: const BorderSide(color: Colors.deepOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ]
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reimprimer(context),
                  icon: const Icon(Symbols.print, size: 16),
                  label: const Text('Réimprimer', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loadingRetour ? null : () => _confirmerRetour(context),
                  icon: _loadingRetour
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Symbols.undo, size: 16),
                  label: const Text('Retour', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Widgets filtres ───────────────────────────────────────────────────────────

class _FiltreChip extends StatelessWidget {
  const _FiltreChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.color,
    this.onClear,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
            left: 10, top: 5, bottom: 5, right: onClear != null ? 4 : 10),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? c : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? c : AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...
              [
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Symbols.close, size: 13, color: c),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onClear,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.calendar_month,
                size: 13,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Symbols.close,
                    size: 12, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Dialog reçu de retour ─────────────────────────────────────────────────────

class RetourReceiptDialog extends StatelessWidget {
  const RetourReceiptDialog({
    super.key,
    required this.resume,
    required this.dateRetour,
  });
  final VenteResume resume;
  final String dateRetour;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Symbols.undo, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text('Reçu de retour',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Corps
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête boutique
                  Center(
                    child: Column(
                      children: [
                        Text(resume.nomBoutique,
                            style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        const Text('BON DE RETOUR',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.deepOrange,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text(dateRetour,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  const Divider(height: 20),

                  // Articles retournés
                  ...resume.lignes.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Symbols.undo,
                                size: 12, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  '${item.nom} × ${item.quantite}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                            ),
                            Text(
                              '${(item.prixUnitaire * item.quantite).toStringAsFixed(0)} F',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      )),

                  const Divider(height: 16),
                  // Total remboursé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MONTANT REMBOURSÉ',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(
                        '${resume.total.toStringAsFixed(0)} F',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  if (resume.clientNom != null) ...[
                    const SizedBox(height: 8),
                    Text('Client : ${resume.clientNom}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Merci pour votre confiance.',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
