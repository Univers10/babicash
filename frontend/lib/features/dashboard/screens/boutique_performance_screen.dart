import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/dashboard_provider.dart';

final _boutiqueGranulariteProvider = StateProvider<String>((_) => 'mois');

class BoutiquePerformanceScreen extends ConsumerWidget {
  const BoutiquePerformanceScreen({super.key, required this.boutiqueId});
  final String boutiqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granularite = ref.watch(_boutiqueGranulariteProvider);
    final consolideAsync = ref.watch(dashboardConsolideProvider(granularite));
    final boutiqueNom = (GoRouterState.of(context).extra
            as Map<String, dynamic>?)?['nom']
        as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: Text(boutiqueNom ?? 'Performance boutique'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: _PeriodeSelector(
              selected: granularite,
              onChanged: (v) =>
                  ref.read(_boutiqueGranulariteProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: consolideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.cloud_off,
                  size: 48, color: AppColors.textTertiary),
              const VGap(AppSpacing.lg),
              Text('Erreur de chargement',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(
                child: Text('Accès réservé au propriétaire.'));
          }
          final boutiques = data['boutiques'] as List? ?? [];
          final boutique = boutiques.cast<Map<String, dynamic>>().firstWhere(
                (b) => b['boutique_id'] == boutiqueId,
                orElse: () => <String, dynamic>{},
              );
          if (boutique.isEmpty) {
            return const Center(child: Text('Boutique introuvable.'));
          }
          return _PerformanceBody(boutique: boutique);
        },
      ),
    );
  }
}

class _PerformanceBody extends StatelessWidget {
  const _PerformanceBody({required this.boutique});
  final Map<String, dynamic> boutique;

  @override
  Widget build(BuildContext context) {
    final ca = _parseDouble(boutique['chiffre_affaires']);
    final marge = _parseDouble(boutique['marge_nette']);
    final nbVentes = _parseInt(boutique['nb_ventes']);
    final caisse = boutique['caisse'] as Map<String, dynamic>? ?? {};
    final recettes = _parseDouble(caisse['recettes_ventes']);
    final depenses = _parseDouble(caisse['depenses']);
    final soldeNet = _parseDouble(caisse['solde_net']);
    final stock = boutique['stock'] as Map<String, dynamic>? ?? {};
    final nbReferences = _parseInt(stock['nb_references']);
    final valeurStock = _parseDouble(stock['valeur_stock_fcfa']);
    final nbRuptures = _parseInt(stock['nb_ruptures']);
    final nbAlertes = _parseInt(stock['nb_alertes']);
    final dettes = boutique['dettes'] as Map<String, dynamic>? ?? {};
    final totalDettes = _parseDouble(dettes['total_dettes']);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _SectionTitle(title: 'Ventes'),
        _KpiGrid(cells: [
          _KpiData(label: 'CA', value: AmountText.format(ca), color: AppColors.primary),
          _KpiData(
              label: 'Marge nette',
              value: AmountText.format(marge),
              color: marge >= 0 ? AppColors.success : AppColors.error),
          _KpiData(label: 'Ventes', value: '$nbVentes', color: AppColors.textSecondary),
        ]),
        const VGap(AppSpacing.lg),

        const _SectionTitle(title: 'Caisse'),
        _KpiGrid(cells: [
          _KpiData(
              label: 'Recettes', value: AmountText.format(recettes), color: AppColors.success),
          _KpiData(
              label: 'Dépenses', value: AmountText.format(depenses), color: AppColors.error),
          _KpiData(
              label: 'Solde net',
              value: AmountText.format(soldeNet),
              color: soldeNet >= 0 ? AppColors.success : AppColors.error),
        ]),
        const VGap(AppSpacing.lg),

        const _SectionTitle(title: 'Stock'),
        _KpiGrid(cells: [
          _KpiData(
              label: 'Références', value: '$nbReferences', color: AppColors.primary),
          _KpiData(
              label: 'Valeur stock',
              value: AmountText.format(valeurStock),
              color: AppColors.primary),
          _KpiData(
              label: 'Ruptures',
              value: '$nbRuptures',
              color: nbRuptures > 0 ? AppColors.error : AppColors.success),
          _KpiData(
              label: 'Alertes',
              value: '$nbAlertes',
              color: nbAlertes > 0 ? AppColors.warning : AppColors.success),
        ]),
        const VGap(AppSpacing.lg),

        const _SectionTitle(title: 'Dettes'),
        _KpiGrid(cells: [
          _KpiData(
              label: 'Total dettes',
              value: AmountText.format(totalDettes),
              color: AppColors.brown),
        ]),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.cells});
  final List<_KpiData> cells;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.1,
      children: cells
          .map((c) => Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c.label,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                    const VGap(AppSpacing.xs),
                    Text(c.value,
                        style: AppTextStyles.labelLarge.copyWith(
                            color: c.color, fontWeight: FontWeight.w700)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

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
