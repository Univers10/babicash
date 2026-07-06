import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/stock_provider.dart';
import '../widgets/produit_card.dart';
import '../widgets/produit_form_dialog.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.category),
            onPressed: () => context.push(AppRoutes.categories),
          ),
          IconButton(
            icon: const Icon(Symbols.search),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProduitFormDialog(),
        ),
        child: const Icon(Symbols.add),
      ),
      body: stockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erreur : $e', style: AppTextStyles.bodyMedium),
        ),
        data: (produits) {
          if (produits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.inventory_2,
                      size: 64, color: AppColors.textTertiary),
                  const VGap(AppSpacing.lg),
                  Text('Aucun produit',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Badges alertes
          final ruptures = produits.where((p) => p.stockActuel <= 0).length;
          final alertes = produits
              .where((p) => p.stockActuel > 0 && p.stockActuel <= p.stockAlerte)
              .length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(stockProvider),
            child: Column(
              children: [
                if (ruptures > 0 || alertes > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Row(
                      children: [
                        if (ruptures > 0)
                          _AlertBadge(
                            label: '$ruptures rupture${ruptures > 1 ? 's' : ''}',
                            color: AppColors.error,
                            icon: Symbols.warning,
                          ),
                        if (ruptures > 0 && alertes > 0)
                          const HGap(AppSpacing.sm),
                        if (alertes > 0)
                          _AlertBadge(
                            label: '$alertes alerte${alertes > 1 ? 's' : ''}',
                            color: AppColors.warning,
                            icon: Symbols.info,
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: produits.length,
                    separatorBuilder: (_, __) => const VGap(AppSpacing.sm),
                    itemBuilder: (_, i) => ProduitCard(produit: produits[i]),
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

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const HGap(AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
