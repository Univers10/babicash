import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/images/media_url.dart';
import '../../../shared/widgets/amount_text.dart';
import '../utils/categorie_couleur.dart';
import 'mouvement_stock_dialog.dart';
import 'produit_form_dialog.dart';

class ProduitCard extends ConsumerWidget {
  const ProduitCard({super.key, required this.produit});
  final LocalProduit produit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enRupture = produit.stockActuel <= 0;
    final enAlerte =
        !enRupture && produit.stockActuel <= produit.stockAlerte;

    Color stockColor = AppColors.success;
    if (enRupture) { stockColor = AppColors.error; }
    else if (enAlerte) { stockColor = AppColors.warning; }

    // S5 : la carte reprend la couleur de la catégorie (bordure + pastille).
    final couleurCategorie = CategorieCouleur.pour(produit.categorieId);
    final imageUrl = absoluteMediaUrl(ref.watch(apiOriginProvider), produit.imageUrl);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => ProduitFormDialog(produit: produit),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Bordure latérale à la couleur de la catégorie
              Container(width: 4, color: couleurCategorie),
              Expanded(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      // Image produit (ou pastille catégorie en repli)
                      ClipRRect(
                        borderRadius: AppSpacing.borderRadiusMd,
                        child: Container(
                          width: 44,
                          height: 44,
                          color: couleurCategorie.withValues(alpha: 0.14),
                          child: imageUrl.isEmpty
                              ? Icon(Symbols.inventory_2,
                                  color: couleurCategorie, size: 22)
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Icon(
                                      Symbols.inventory_2,
                                      color: couleurCategorie,
                                      size: 22),
                                  errorWidget: (_, __, ___) => Icon(
                                      Symbols.inventory_2,
                                      color: couleurCategorie,
                                      size: 22),
                                ),
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
                          color: stockColor.withValues(alpha: 0.12),
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
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: stockColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),

                      // S2 : entrée / sortie de stock via mouvement tracé
                      IconButton(
                        icon: const Icon(Symbols.swap_vert, size: 22),
                        color: AppColors.textSecondary,
                        tooltip: 'Entrée / Sortie de stock',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              MouvementStockDialog(produit: produit),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
