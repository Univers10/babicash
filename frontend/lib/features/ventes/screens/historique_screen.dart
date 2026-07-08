import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/vente_model.dart';
import '../../../data/remote/ventes_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../shared/widgets/amount_text.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

class _FiltresVentes {
  const _FiltresVentes({
    this.modePaiement,
    this.dateDebut,
    this.dateFin,
    this.search,
    this.signaleSeulement = false,
  });
  final String? modePaiement;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? search;
  final bool signaleSeulement;

  _FiltresVentes copyWith({
    Object? modePaiement = _sentinel,
    Object? dateDebut = _sentinel,
    Object? dateFin = _sentinel,
    Object? search = _sentinel,
    bool? signaleSeulement,
  }) =>
      _FiltresVentes(
        modePaiement: modePaiement == _sentinel ? this.modePaiement : modePaiement as String?,
        dateDebut: dateDebut == _sentinel ? this.dateDebut : dateDebut as DateTime?,
        dateFin: dateFin == _sentinel ? this.dateFin : dateFin as DateTime?,
        search: search == _sentinel ? this.search : search as String?,
        signaleSeulement: signaleSeulement ?? this.signaleSeulement,
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

  @override
  Widget build(BuildContext context) {
    final filtres = ref.watch(_filtresProvider);
    final ventesAsync = ref.watch(_ventesProvider);
    final hasFiltre = filtres.modePaiement != null ||
        filtres.dateDebut != null ||
        filtres.dateFin != null ||
        (filtres.search?.isNotEmpty ?? false) ||
        filtres.signaleSeulement;

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
                    Text('Erreur: $e',
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

class _VenteTile extends StatelessWidget {
  const _VenteTile({required this.vente, required this.fmt});
  final VenteHistorique vente;
  final DateFormat fmt;

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
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: vente.signaleProprietaire
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          vente.signaleProprietaire
              ? Symbols.warning
              : Symbols.receipt_long,
          size: 20,
          color: vente.signaleProprietaire
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        fmt.format(vente.dateVente.toLocal()),
        style:
            AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
      ),
      trailing: AmountText(
        amount: vente.montantTotal,
        style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      ),
      children: vente.lignes.map((l) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                l.venteAPerte
                    ? Symbols.trending_down
                    : Symbols.circle,
                size: 10,
                color: l.venteAPerte
                    ? AppColors.error
                    : AppColors.textDisabled,
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
      }).toList(),
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
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
