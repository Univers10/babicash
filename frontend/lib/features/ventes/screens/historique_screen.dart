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
import '../../../shared/widgets/menu_button.dart';

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

  Future<void> _showFiltresSheet(BuildContext context, _FiltresVentes filtres) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final current = ref.watch(_filtresProvider);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Filtres', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    // Période
                    Text('Période', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DateChip(
                            label: current.dateDebut != null
                                ? 'Du ${_fmtDate.format(current.dateDebut!)}'
                                : 'Date début',
                            selected: current.dateDebut != null,
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: current.dateDebut ?? DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) {
                                ref.read(_filtresProvider.notifier).state = current.copyWith(dateDebut: d);
                              }
                            },
                            onClear: current.dateDebut != null
                                ? () => ref.read(_filtresProvider.notifier).state = current.copyWith(dateDebut: null)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DateChip(
                            label: current.dateFin != null
                                ? 'Au ${_fmtDate.format(current.dateFin!)}'
                                : 'Date fin',
                            selected: current.dateFin != null,
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: current.dateFin ?? DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) {
                                ref.read(_filtresProvider.notifier).state = current.copyWith(dateFin: d);
                              }
                            },
                            onClear: current.dateFin != null
                                ? () => ref.read(_filtresProvider.notifier).state = current.copyWith(dateFin: null)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Options
                    Text('Options', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _OptionTile(
                      label: 'Vendeur',
                      value: current.caissierNom,
                      icon: Symbols.person,
                      onTap: () {
                        Navigator.pop(ctx);
                        _choisirVendeur(context, current);
                      },
                      onClear: current.caissierId != null
                          ? () => ref.read(_filtresProvider.notifier).state = current.copyWith(caissierId: null, caissierNom: null)
                          : null,
                    ),
                    _OptionTile(
                      label: 'Ventes signalées seulement',
                      value: current.signaleSeulement ? 'Oui' : null,
                      icon: Symbols.warning,
                      color: AppColors.error,
                      onTap: () => ref.read(_filtresProvider.notifier).state = current.copyWith(signaleSeulement: !current.signaleSeulement),
                      onClear: current.signaleSeulement
                          ? () => ref.read(_filtresProvider.notifier).state = current.copyWith(signaleSeulement: false)
                          : null,
                    ),
                    _OptionTile(
                      label: 'Inclure les retours',
                      value: current.includeRetours ? 'Oui' : null,
                      icon: Symbols.undo,
                      color: Colors.deepOrange,
                      onTap: () => ref.read(_filtresProvider.notifier).state = current.copyWith(includeRetours: !current.includeRetours),
                      onClear: current.includeRetours
                          ? () => ref.read(_filtresProvider.notifier).state = current.copyWith(includeRetours: false)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(_filtresProvider.notifier).state = const _FiltresVentes();
                        },
                        icon: const Icon(Symbols.filter_list_off, size: 18),
                        label: const Text('Réinitialiser tous les filtres'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        leading: const MenuButton(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Historique des ventes',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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
                // Filtres rapides : modes de paiement + accès filtres avancés
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
                      _FiltreAvancesChip(
                        filtres: filtres,
                        onTap: () => _showFiltresSheet(context, filtres),
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
                    _ResumeVentes(ventes: resp.ventes),
                    const Divider(height: 1),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => ref.invalidate(_ventesProvider),
                        child: _VentesListView(ventes: resp.ventes, fmt: _fmt),
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

// ── Widgets filtres ───────────────────────────────────────────────────────────

class _FiltreChip extends StatelessWidget {
  const _FiltreChip({
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
            Icon(icon,
                size: 13,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textSecondary,
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

class _FiltreAvancesChip extends StatelessWidget {
  const _FiltreAvancesChip({required this.filtres, required this.onTap});
  final _FiltresVentes filtres;
  final VoidCallback onTap;

  bool get _actif =>
      filtres.dateDebut != null ||
      filtres.dateFin != null ||
      filtres.caissierId != null ||
      filtres.signaleSeulement ||
      filtres.includeRetours;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _actif ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _actif ? AppColors.primary : AppColors.border,
            width: _actif ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.tune,
              size: 13,
              color: _actif ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Filtres',
              style: TextStyle(
                fontSize: 11,
                fontWeight: _actif ? FontWeight.w600 : FontWeight.w400,
                color: _actif ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (_actif) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    this.value,
    required this.icon,
    this.color,
    required this.onTap,
    this.onClear,
  });
  final String label;
  final String? value;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final isActive = value != null && value!.isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 48,
      leading: Icon(icon, size: 20, color: isActive ? c : AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: isActive
          ? Text(
              value!,
              style: AppTextStyles.caption.copyWith(color: c),
            )
          : null,
      trailing: isActive && onClear != null
          ? IconButton(
              icon: Icon(Symbols.close, size: 18, color: c),
              onPressed: onClear,
            )
          : const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ── Résumé & liste groupée ─────────────────────────────────────────────────────

String _labelGroupe(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Aujourd\'hui';
  if (diff == 1) return 'Hier';
  if (diff < 7) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jours[date.weekday - 1];
  }
  return DateFormat('dd MMM yyyy').format(date);
}

class _ResumeVentes extends StatelessWidget {
  const _ResumeVentes({required this.ventes});
  final List<VenteHistorique> ventes;

  @override
  Widget build(BuildContext context) {
    final total = ventes.fold<double>(0, (s, v) => s + v.montantTotal);
    final especes = ventes.where((v) => v.modePaiement == 'ESPECES').fold<double>(0, (s, v) => s + v.montantTotal);
    final mobile = ventes.where((v) => v.modePaiement == 'MOBILE_MONEY').fold<double>(0, (s, v) => s + v.montantTotal);
    final credit = ventes.where((v) => v.modePaiement == 'CREDIT').fold<double>(0, (s, v) => s + v.montantTotal);

    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ResumeCard(
                  label: 'Ventes',
                  value: '${ventes.length}',
                  icon: Symbols.receipt_long,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumeCard(
                  label: 'Total',
                  value: '${total.toStringAsFixed(0)} F',
                  icon: Symbols.payments,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MiniBadge(label: 'Espèces', value: '${especes.toStringAsFixed(0)} F', color: AppColors.success),
                const SizedBox(width: 8),
                _MiniBadge(label: 'Mobile', value: '${mobile.toStringAsFixed(0)} F', color: Colors.blue),
                const SizedBox(width: 8),
                _MiniBadge(label: 'Crédit', value: '${credit.toStringAsFixed(0)} F', color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 6),
          Text('$label: ', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _VentesListView extends StatelessWidget {
  const _VentesListView({required this.ventes, required this.fmt});
  final List<VenteHistorique> ventes;
  final DateFormat fmt;

  List<_VenteItem> get _items {
    final map = <String, List<VenteHistorique>>{};
    for (final v in ventes) {
      final label = _labelGroupe(v.dateVente.toLocal());
      map.putIfAbsent(label, () => []).add(v);
    }
    const order = ['Aujourd\'hui', 'Hier', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final sortedKeys = map.keys.toList()..sort((a, b) {
      final ia = order.indexOf(a);
      final ib = order.indexOf(b);
      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;
      return a.compareTo(b);
    });
    final items = <_VenteItem>[];
    for (final key in sortedKeys) {
      items.add(_VenteItem.header(key));
      final list = map[key]!..sort((a, b) => b.dateVente.compareTo(a.dateVente));
      items.addAll(list.map((v) => _VenteItem.vente(v)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, i) => items[i].isHeader || (i + 1 < items.length && items[i + 1].isHeader)
          ? const SizedBox.shrink()
          : const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (ctx, i) {
        final item = items[i];
        if (item.isHeader) return _DateHeader(label: item.label!);
        return _VenteTile(vente: item.vente!, fmt: fmt);
      },
    );
  }
}

class _VenteItem {
  _VenteItem._({this.label, this.vente});
  final String? label;
  final VenteHistorique? vente;
  bool get isHeader => vente == null;

  factory _VenteItem.header(String label) => _VenteItem._(label: label);
  factory _VenteItem.vente(VenteHistorique v) => _VenteItem._(vente: v);
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VenteTile extends StatelessWidget {
  const _VenteTile({required this.vente, required this.fmt});
  final VenteHistorique vente;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _ModeAvatar(mode: vente.modePaiement, statut: vente.statut),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vente.clientNom ?? 'Vente directe',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(vente: vente),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vente.caissierNom != null
                        ? '${fmt.format(vente.dateVente.toLocal())} · ${vente.caissierNom}'
                        : fmt.format(vente.dateVente.toLocal()),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  if (vente.lignes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      vente.lignes.map((l) => '${l.produitNom ?? 'Article'} × ${l.quantite}').join(', '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(
                  amount: vente.montantTotal,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: vente.statut == 'RETOURNEE' ? Colors.deepOrange : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    decoration: vente.statut == 'RETOURNEE' ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.deepOrange,
                  ),
                ),
                _ModeChip(mode: vente.modePaiement),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VenteDetailSheet(vente: vente),
    );
  }
}

class _ModeAvatar extends StatelessWidget {
  const _ModeAvatar({required this.mode, required this.statut});
  final String mode;
  final String statut;

  @override
  Widget build(BuildContext context) {
    final isRetour = statut == 'RETOURNEE';
    final color = isRetour ? Colors.deepOrange : _modeColor(mode);
    final icon = isRetour ? Symbols.undo : _modeIcon(mode);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode});
  final String mode;

  @override
  Widget build(BuildContext context) {
    final color = _modeColor(mode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _modeLabel(mode),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.vente});
  final VenteHistorique vente;

  @override
  Widget build(BuildContext context) {
    if (vente.statut == 'RETOURNEE') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('Retourné', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
      );
    }
    if (vente.signaleProprietaire) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('Signalé', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.error)),
      );
    }
    return const SizedBox.shrink();
  }
}

Color _modeColor(String mode) {
  switch (mode) {
    case 'CREDIT': return Colors.orange;
    case 'MOBILE_MONEY': return Colors.blue;
    default: return AppColors.success;
  }
}

IconData _modeIcon(String mode) {
  switch (mode) {
    case 'CREDIT': return Symbols.credit_card;
    case 'MOBILE_MONEY': return Symbols.phone_android;
    default: return Symbols.payments;
  }
}

String _modeLabel(String mode) {
  switch (mode) {
    case 'CREDIT': return 'Crédit';
    case 'MOBILE_MONEY': return 'Mobile';
    default: return 'Espèces';
  }
}

class _VenteDetailSheet extends ConsumerStatefulWidget {
  const _VenteDetailSheet({required this.vente});
  final VenteHistorique vente;

  @override
  ConsumerState<_VenteDetailSheet> createState() => _VenteDetailSheetState();
}

class _VenteDetailSheetState extends ConsumerState<_VenteDetailSheet> {
  bool _loadingRetour = false;

  VenteHistorique get vente => widget.vente;

  VenteResume _toResume() {
    final lignes = vente.lignes.map((l) => PanierItem(
      produitId: l.produitId,
      nom: l.produitNom ?? 'Article libre',
      prixUnitaire: l.prixVenduReel,
      prixAchat: 0,
      quantite: l.quantite,
      remise: 0,
    )).toList();

    final recu = ref.read(receiptConfigProvider).valueOrNull ?? const ReceiptConfig();
    final boutique = ref.read(boutiqueInfoProvider).valueOrNull;
    final logoAbs = absoluteMediaUrl(ref.read(apiOriginProvider), boutique?.logoUrl);
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

  Future<void> _reimprimer() async {
    final resume = _toResume();
    Navigator.pop(context);
    showDialog(context: context, builder: (_) => TicketDialog(vente: resume));
  }

  Future<void> _imprimerRetour() async {
    final resume = _toResume();
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    final dateLabel = vente.dateRetour != null
        ? fmtDate.format(vente.dateRetour!.toLocal())
        : fmtDate.format(DateTime.now());
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => RetourReceiptDialog(resume: resume, dateRetour: dateLabel),
    );
  }

  Future<void> _confirmerRetour() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Retour marchandise'),
        content: Text(
          'Annuler cette vente de ${vente.montantTotal.toStringAsFixed(0)} F ?\n'
          'Le stock des produits sera remis à jour.'
          '${vente.modePaiement == "CREDIT" ? "\nLe solde client sera aussi ajusté." : ""}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirmer le retour', style: TextStyle(color: Colors.white)),
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Retour effectué. Stock remis à jour.'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors du retour'),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _loadingRetour = false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, HH:mm');
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ModeAvatar(mode: vente.modePaiement, statut: vente.statut),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vente.clientNom ?? 'Vente directe',
                          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          fmt.format(vente.dateVente.toLocal()),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AmountText(
                        amount: vente.montantTotal,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: vente.statut == 'RETOURNEE' ? Colors.deepOrange : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          decoration: vente.statut == 'RETOURNEE' ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.deepOrange,
                        ),
                      ),
                      _ModeChip(mode: vente.modePaiement),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Articles', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...vente.lignes.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: l.venteAPerte ? AppColors.error : AppColors.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.produitNom ?? 'Article libre',
                                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${l.prixVenduReel.toStringAsFixed(0)} F × ${l.quantite}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        AmountText(
                          amount: l.prixVenduReel * l.quantite,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      AmountText(
                        amount: vente.montantTotal,
                        style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (vente.caissierNom != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Vendeur : ${vente.caissierNom}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if (vente.statut == 'RETOURNEE' && vente.dateRetour != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Retourné le ${DateFormat('dd/MM/yyyy HH:mm').format(vente.dateRetour!.toLocal())}',
                      style: AppTextStyles.caption.copyWith(color: Colors.deepOrange),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SafeArea(
                child: vente.statut == 'RETOURNEE'
                    ? SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _imprimerRetour(),
                          icon: const Icon(Symbols.print, size: 18),
                          label: const Text('Reçu de retour'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            side: const BorderSide(color: Colors.deepOrange),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _reimprimer(),
                              icon: const Icon(Symbols.print, size: 18),
                              label: const Text('Réimprimer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loadingRetour ? null : () => _confirmerRetour(),
                              icon: _loadingRetour
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Symbols.undo, size: 18),
                              label: const Text('Retour'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
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
