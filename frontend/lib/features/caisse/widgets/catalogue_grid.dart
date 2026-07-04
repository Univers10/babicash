import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../features/stock/providers/stock_provider.dart';
import '../../../shared/widgets/amount_text.dart';

class CatalogueGrid extends ConsumerWidget {
  const CatalogueGrid({super.key, required this.onProduitTap});
  final void Function(LocalProduit) onProduitTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockProvider);

    return stockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('Erreur de chargement', style: AppTextStyles.bodyMedium)),
      data: (produits) {
        if (produits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.inventory_2,
                    size: 48, color: AppColors.textTertiary),
                const VGap(AppSpacing.md),
                Text('Aucun produit dans le catalogue',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: produits.length,
          itemBuilder: (_, i) => _ProduitTile(
            produit: produits[i],
            onTap: () => onProduitTap(produits[i]),
          ),
        );
      },
    );
  }
}

class _ProduitTile extends StatelessWidget {
  const _ProduitTile({required this.produit, required this.onTap});
  final LocalProduit produit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.stockActuel <= 0;

    return Material(
      color: enRupture ? AppColors.surfaceVariant : AppColors.surface,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: enRupture ? null : onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: enRupture ? AppColors.borderLight : AppColors.borderLight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enRupture
                      ? AppColors.borderLight
                      : AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  Symbols.inventory_2,
                  size: 20,
                  color: enRupture
                      ? AppColors.textDisabled
                      : AppColors.primary,
                ),
              ),
              const VGap(AppSpacing.xs),
              Text(
                produit.nom,
                style: AppTextStyles.labelMedium.copyWith(
                  color: enRupture
                      ? AppColors.textDisabled
                      : AppColors.textPrimary,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const VGap(2),
              AmountText(
                amount: produit.prixVenteSuggere,
                style: AppTextStyles.caption.copyWith(
                  color: enRupture
                      ? AppColors.textDisabled
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                showCurrency: false,
              ),
              if (enRupture)
                Text('Rupture',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
