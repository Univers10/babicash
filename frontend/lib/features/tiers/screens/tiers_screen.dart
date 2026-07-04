import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/amount_text.dart';
import '../providers/tiers_provider.dart';

class TiersScreen extends ConsumerWidget {
  const TiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(tiersTypeProvider);
    final tiersAsync = ref.watch(tiersProvider(type));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clients & Fournisseurs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Clients',
                  selected: type == 'CLIENT',
                  onTap: () => ref.read(tiersTypeProvider.notifier).state = 'CLIENT',
                ),
                const HGap(AppSpacing.sm),
                _TypeChip(
                  label: 'Fournisseurs',
                  selected: type == 'FOURNISSEUR',
                  onTap: () => ref.read(tiersTypeProvider.notifier).state = 'FOURNISSEUR',
                ),
              ],
            ),
          ),
        ),
      ),
      body: tiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur', style: AppTextStyles.bodyMedium)),
        data: (tiers) {
          if (tiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == 'CLIENT' ? Symbols.person : Symbols.store,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const VGap(AppSpacing.lg),
                  Text(
                    type == 'CLIENT'
                        ? 'Aucun client enregistré'
                        : 'Aucun fournisseur enregistré',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          // Total dettes
          final totalDu =
              tiers.fold(0.0, (sum, t) => sum + t.soldeDu);

          return Column(
            children: [
              if (totalDu > 0)
                Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: AppSpacing.borderRadiusMd,
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.account_balance,
                          color: AppColors.warning, size: 20),
                      const HGap(AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total dû',
                              style: AppTextStyles.caption,
                            ),
                            AmountText(
                              amount: totalDu,
                              style: AppTextStyles.amountMedium.copyWith(
                                  color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  itemCount: tiers.length,
                  separatorBuilder: (_, __) =>
                      const VGap(AppSpacing.sm),
                  itemBuilder: (_, i) => _TierCard(tier: tiers[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});
  final LocalTier tier;

  @override
  Widget build(BuildContext context) {
    final hasDette = tier.soldeDu > 0;
    final isClient = tier.typeTiers == 'CLIENT';

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isClient
                    ? AppColors.primaryContainer
                    : AppColors.accentContainer,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Icon(
                isClient ? Symbols.person : Symbols.store,
                size: 22,
                color: isClient ? AppColors.primary : AppColors.accent,
              ),
            ),
            const HGap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier.nom,
                      style: AppTextStyles.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (tier.telephone != null)
                    Text(tier.telephone!,
                        style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (hasDette)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Doit',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error)),
                  AmountText(
                    amount: tier.soldeDu,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
