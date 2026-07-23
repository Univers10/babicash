import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../data/local/database.dart';
import '../../../features/stock/providers/stock_provider.dart';
import '../../../shared/images/media_url.dart';
import '../../../shared/utils/categorie_utils.dart';
import '../providers/caisse_provider.dart';

// Provider pour la catégorie sélectionnée
final _selectedCategoryProvider = StateProvider<String?>((_) => null);

/// Identifiant virtuel du filtre « Sans catégorie » (produits avec
/// `categorieId == null`). Purement UI : jamais persisté en base.
const kSansCategorieId = '__sans_categorie__';

// Couleurs neutres pour le regroupement virtuel « Sans catégorie »
const _sansCategorieColor = Color(0xFF607D8B); // gris bleu
const _sansCategorieBgColor = Color(0xFFECEFF1);

// Palette de couleurs pour les catégories (style Odoo POS)
const _categoryColors = [
  Color(0xFF1B6B2F), // vert foncé
  Color(0xFFE8A838), // doré
  Color(0xFF2196F3), // bleu
  Color(0xFFE91E63), // rose
  Color(0xFF9C27B0), // violet
  Color(0xFFFF5722), // orange
  Color(0xFF00BCD4), // cyan
  Color(0xFF795548), // marron
  Color(0xFF607D8B), // gris bleu
  Color(0xFF4CAF50), // vert clair
];

const _categoryBgColors = [
  Color(0xFFE8F5E9), // vert clair bg
  Color(0xFFFFF8E1), // doré bg
  Color(0xFFE3F2FD), // bleu bg
  Color(0xFFFCE4EC), // rose bg
  Color(0xFFF3E5F5), // violet bg
  Color(0xFFFBE9E7), // orange bg
  Color(0xFFE0F7FA), // cyan bg
  Color(0xFFEFEBE9), // marron bg
  Color(0xFFECEFF1), // gris bleu bg
  Color(0xFFE8F5E9), // vert clair bg
];

class CatalogueGrid extends ConsumerWidget {
  const CatalogueGrid({
    super.key,
    required this.onProduitTap,
    this.searchQuery = '',
    this.bottomPadding = 0,
  });
  final void Function(LocalProduit) onProduitTap;
  final String searchQuery;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCatId = ref.watch(_selectedCategoryProvider);
    final apiOrigin = ref.watch(apiOriginProvider);
    // C3 : quantités du panier par produit — badge mis à jour en temps réel
    final panier = ref.watch(panierProvider);
    final qteAuPanier = <String, int>{};
    for (final item in panier) {
      final id = item.produitId;
      if (id != null) qteAuPanier[id] = (qteAuPanier[id] ?? 0) + item.quantite;
    }
    final screenW = MediaQuery.of(context).size.width;
    final crossCount = screenW > 900
        ? 5
        : screenW > 600
            ? 4
            : 3;

    // Catégories triées (insensible à la casse et aux accents) ; les couleurs
    // suivent l'ordre trié pour rester cohérentes entre puces et tuiles.
    final categories = [...(categoriesAsync.valueOrNull ?? <LocalCategory>[])]
      ..sort((a, b) => comparerSansAccents(a.nom, b.nom));
    final catColorMap = <String, int>{};
    for (int i = 0; i < categories.length; i++) {
      catColorMap[categories[i].id] = i % _categoryColors.length;
    }
    // C5 : y a-t-il des produits sans catégorie ? (regroupement virtuel)
    final hasSansCategorie = (stockAsync.valueOrNull ?? const <LocalProduit>[])
        .any((p) => p.categorieId == null);

    return Column(
      children: [
        // ── Barre de catégories ─────────────────────────────────────────
        categoriesAsync.when(
          loading: () => const SizedBox(height: 48),
          error: (_, __) => const SizedBox(height: 48),
          data: (_) {
            if (categories.isEmpty) return const SizedBox.shrink();
            final itemCount =
                1 + categories.length + (hasSansCategorie ? 1 : 0);
            return Container(
              height: 48,
              color: AppColors.background,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    final isSelected = selectedCatId == null;
                    return _CategoryChip(
                      label: 'Tout',
                      color: AppColors.primary,
                      isSelected: isSelected,
                      onTap: () => ref.read(_selectedCategoryProvider.notifier).state = null,
                    );
                  }
                  // Puce virtuelle « Sans catégorie », toujours en dernier
                  if (hasSansCategorie && i == itemCount - 1) {
                    final isSelected = selectedCatId == kSansCategorieId;
                    return _CategoryChip(
                      label: sansCategorieLabel,
                      color: _sansCategorieColor,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(_selectedCategoryProvider.notifier)
                          .state = isSelected ? null : kSansCategorieId,
                    );
                  }
                  final cat = categories[i - 1];
                  final isSelected = selectedCatId == cat.id;
                  final colorIdx = catColorMap[cat.id] ?? 0;
                  return _CategoryChip(
                    label: cat.nom,
                    color: _categoryColors[colorIdx],
                    isSelected: isSelected,
                    onTap: () => ref.read(_selectedCategoryProvider.notifier).state =
                        isSelected ? null : cat.id,
                  );
                },
              ),
            );
          },
        ),
        // ── Grille produits ─────────────────────────────────────────────
        Expanded(
          child: stockAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white54)),
            error: (e, _) => Center(
                child: Text('Erreur de chargement',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white54))),
            data: (tous) {
              var produits = tous.toList();

              // Filtre par catégorie (dont regroupement virtuel « Sans catégorie »)
              if (selectedCatId == kSansCategorieId) {
                produits =
                    produits.where((p) => p.categorieId == null).toList();
              } else if (selectedCatId != null) {
                produits = produits
                    .where((p) => p.categorieId == selectedCatId)
                    .toList();
              }

              // Filtre par recherche
              if (searchQuery.isNotEmpty) {
                produits = produits
                    .where((p) => p.nom
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();
              }

              if (produits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.search_off,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'Aucun produit dans cette catégorie'
                            : 'Aucun résultat pour "$searchQuery"',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                );
              }

              // Grille à hauteur adaptative : chaque tuile prend la hauteur
              // qu'il lui faut → le nom complet s'affiche, même long, sans
              // troncature ni débordement.
              return MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomPadding),
                crossAxisCount: crossCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                itemCount: produits.length,
                itemBuilder: (_, i) {
                  final p = produits[i];
                  final cIdx = catColorMap[p.categorieId];
                  return _ProduitTile(
                    produit: p,
                    imageUrl: absoluteMediaUrl(apiOrigin, p.imageUrl),
                    accentColor:
                        cIdx != null ? _categoryColors[cIdx] : _sansCategorieColor,
                    bgColor: cIdx != null
                        ? _categoryBgColors[cIdx]
                        : _sansCategorieBgColor,
                    quantiteAuPanier: qteAuPanier[p.id] ?? 0,
                    onTap: () => onProduitTap(p),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Chip catégorie ──────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProduitTile extends StatelessWidget {
  const _ProduitTile({
    required this.produit,
    required this.imageUrl,
    required this.accentColor,
    required this.bgColor,
    required this.quantiteAuPanier,
    required this.onTap,
  });
  final LocalProduit produit;
  final String imageUrl;
  final Color accentColor;
  final Color bgColor;
  final int quantiteAuPanier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.stockActuel <= 0;
    final effectiveAccent = enRupture ? AppColors.textDisabled : accentColor;
    final effectiveBg = enRupture ? AppColors.surfaceVariant : bgColor;

    // Repli sans image : fond teinté + icône centrée (remplit toute la zone).
    Widget fallback() => Container(
          color: effectiveAccent.withValues(alpha: 0.12),
          alignment: Alignment.center,
          child: Icon(Symbols.inventory_2, size: 34, color: effectiveAccent),
        );

    return Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enRupture ? null : onTap,
        splashColor: effectiveAccent.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image carrée en haut (style fast-food) ; hauteur fixe pour
            // que seule la zone texte varie selon la longueur du nom.
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isEmpty)
                    fallback()
                  else
                    Opacity(
                      opacity: enRupture ? 0.45 : 1,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => fallback(),
                        errorWidget: (_, __, ___) => fallback(),
                      ),
                    ),
                  // Badges (stock + quantité au panier)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge rupture
                        if (enRupture)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Rupture',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        // Badge stock faible
                        if (!enRupture &&
                            produit.stockActuel <= produit.stockAlerte)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('⚠',
                                style: TextStyle(fontSize: 9)),
                          ),
                        // Badge quantité au panier (C3) — temps réel
                        if (quantiteAuPanier > 0) ...[
                          if (enRupture ||
                              produit.stockActuel <= produit.stockAlerte)
                            const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            constraints: const BoxConstraints(minWidth: 20),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Text(
                              '$quantiteAuPanier',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Nom + prix
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom complet : pas de limite de lignes, il s'enroule et la
                  // tuile s'agrandit en conséquence (grille masonry).
                  Text(
                    produit.nom,
                    style: TextStyle(
                      color: enRupture
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${produit.prixVenteSuggere.toStringAsFixed(0)} F',
                    style: TextStyle(
                      color: effectiveAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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
