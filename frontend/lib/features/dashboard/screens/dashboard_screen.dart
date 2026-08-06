import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granularite = ref.watch(dashboardGranulariteProvider);
    final consolideAsync = ref.watch(dashboardConsolideProvider(granularite));
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            if (user != null)
              Text(user.nom, style: AppTextStyles.caption),
          ],
        ),
        actions: [
          // Sélecteur période
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: _PeriodeSelector(
              selected: granularite,
              onChanged: (v) =>
                  ref.read(dashboardGranulariteProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: consolideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final msg = e is AppException ? e.message : 'Erreur de chargement';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.cloud_off,
                    size: 48, color: AppColors.textTertiary),
                const VGap(AppSpacing.lg),
                Text(msg,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const VGap(AppSpacing.lg),
                TextButton.icon(
                  onPressed: () => ref.invalidate(dashboardConsolideProvider),
                  icon: const Icon(Symbols.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        },
        data: (data) {
          if (data == null) {
            return const Center(
                child: Text('Accès réservé au propriétaire.'));
          }
          return _DashboardBody(data: data);
        },
      ),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

// ── Corps dashboard ───────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final boutiques = data['boutiques'] as List? ?? [];
    final caTotal = _parseDouble(data['ca_total']);
    final margeTotal = _parseDouble(data['marge_totale']);
    final nbVentes = _parseInt(data['nb_ventes_total']);

    final totalStock = boutiques.fold<double>(
        0,
        (s, b) =>
            s + _parseDouble((b['stock']?['valeur_stock_fcfa'])));
    final totalDettes = boutiques.fold<double>(
        0, (s, b) => s + _parseDouble(b['dettes']?['total_dettes']));

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Bannière CA global
          _HeroBanner(
            ca: caTotal,
            marge: margeTotal,
            nbVentes: nbVentes,
            stockValue: totalStock,
            dettes: totalDettes,
          ),
          const VGap(AppSpacing.xl),

          // Titre boutiques
          Text(
            '${boutiques.length} boutique${boutiques.length > 1 ? 's' : ''}',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const VGap(AppSpacing.md),

          // Cards par boutique
          ...boutiques.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BoutiqueCard(boutique: b as Map<String, dynamic>),
              )),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.ca,
    required this.marge,
    required this.nbVentes,
    required this.stockValue,
    required this.dettes,
  });
  final double ca;
  final double marge;
  final int nbVentes;
  final double stockValue;
  final double dettes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chiffre d\'affaires',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white70)),
          const VGap(AppSpacing.xs),
          AmountText(
            amount: ca,
            style: AppTextStyles.amountHero
                .copyWith(color: Colors.white),
          ),
          const VGap(AppSpacing.lg),
          Row(
            children: [
              _MiniKpi(
                label: 'Marge nette',
                value: AmountText.format(marge),
                icon: Symbols.trending_up,
              ),
              const HGap(AppSpacing.xl),
              _MiniKpi(
                label: 'Ventes',
                value: '$nbVentes',
                icon: Symbols.receipt,
              ),
            ],
          ),
          const VGap(AppSpacing.md),
          Row(
            children: [
              _MiniKpi(
                label: 'Valeur stock',
                value: AmountText.format(stockValue),
                icon: Symbols.inventory_2,
              ),
              const HGap(AppSpacing.xl),
              _MiniKpi(
                label: 'Dettes',
                value: AmountText.format(dettes),
                icon: Symbols.account_balance,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const HGap(AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white70)),
            Text(value,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ],
    );
  }
}

class _BoutiqueCard extends StatelessWidget {
  const _BoutiqueCard({required this.boutique});
  final Map<String, dynamic> boutique;

  @override
  Widget build(BuildContext context) {
    final id = boutique['boutique_id'] as String? ?? '';
    final nom = boutique['boutique_nom'] as String? ?? '—';
    final ca = _parseDouble(boutique['chiffre_affaires']);
    final marge = _parseDouble(boutique['marge_nette']);
    final nbVentes = _parseInt(boutique['nb_ventes']);
    final soldeNet = _parseDouble(boutique['caisse']?['solde_net']);
    final valeurStock = _parseDouble(boutique['stock']?['valeur_stock_fcfa']);
    final nbRuptures = _parseInt(boutique['stock']?['nb_ruptures']);
    final nbAlertes = _parseInt(boutique['stock']?['nb_alertes']);
    final totalDettes = _parseDouble(boutique['dettes']?['total_dettes']);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.push('/dashboard/boutique/$id', extra: {'nom': nom}),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: const Icon(Symbols.store,
                        size: 18, color: AppColors.primary),
                  ),
                  const HGap(AppSpacing.md),
                  Expanded(
                    child: Text(nom,
                        style: AppTextStyles.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '$nbVentes vente${nbVentes > 1 ? 's' : ''}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const VGap(AppSpacing.md),
              const Divider(height: 1),
              const VGap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _KpiCell(
                      label: 'CA',
                      value: AmountText.format(ca),
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _KpiCell(
                      label: 'Marge nette',
                      value: AmountText.format(marge),
                      color: marge >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              const VGap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _KpiCell(
                      label: 'Solde net',
                      value: AmountText.format(soldeNet),
                      color: soldeNet >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  Expanded(
                    child: _KpiCell(
                      label: 'Valeur stock',
                      value: AmountText.format(valeurStock),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const VGap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _KpiCell(
                      label: 'Ruptures',
                      value: '$nbRuptures',
                      color: nbRuptures > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _KpiCell(
                      label: 'Alertes',
                      value: '$nbAlertes',
                      color: nbAlertes > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _KpiCell(
                      label: 'Dettes',
                      value: AmountText.format(totalDettes),
                      color: AppColors.brown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        const VGap(2),
        Text(value,
            style: AppTextStyles.amountMedium.copyWith(color: color)),
      ],
    );
  }
}

// ── Sélecteur de période ──────────────────────────────────────────────────────

class _PeriodeSelector extends StatelessWidget {
  const _PeriodeSelector({
    required this.selected,
    required this.onChanged,
  });
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['jour', 'semaine', 'mois'];
    final labels = {'jour': 'Jour', 'semaine': 'Sem.', 'mois': 'Mois'};

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                labels[opt]!,
                style: AppTextStyles.labelMedium.copyWith(
                  color:
                      isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
