import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/amount_text.dart';

class ProduitCard extends StatelessWidget {
  const ProduitCard({super.key, required this.produit});
  final LocalProduit produit;

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.stockActuel <= 0;
    final enAlerte =
        !enRupture && produit.stockActuel <= produit.stockAlerte;

    Color stockColor = AppColors.success;
    if (enRupture) stockColor = AppColors.error;
    else if (enAlerte) stockColor = AppColors.warning;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Icône produit
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: const Icon(
                Symbols.inventory_2,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const HGap(AppSpacing.md),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produit.nom,
                      style: AppTextStyles.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const VGap(2),
                  AmountText(
                    amount: produit.prixVenteSuggere,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Stock badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: stockColor.withOpacity(0.12),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (enRupture || enAlerte)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        enRupture ? Symbols.warning : Symbols.info,
                        size: 12,
                        color: stockColor,
                      ),
                    ),
                  Text(
                    '${produit.stockActuel}',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: stockColor, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
