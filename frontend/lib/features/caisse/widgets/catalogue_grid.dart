import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../features/stock/providers/stock_provider.dart';

// Provider pour la catégorie sélectionnée
final _selectedCategoryProvider = StateProvider<String?>((_) => null);

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
    final screenW = MediaQuery.of(context).size.width;
    final crossCount = screenW > 900
        ? 5
        : screenW > 600
            ? 4
            : 3;

    // Construire un map catId -> colorIndex
    final categories = categoriesAsync.valueOrNull ?? [];
    final catColorMap = <String, int>{};
    for (int i = 0; i < categories.length; i++) {
      catColorMap[categories[i].id] = i % _categoryColors.length;
    }

    return Column(
      children: [
        // ── Barre de catégories ─────────────────────────────────────────
        categoriesAsync.when(
          loading: () => const SizedBox(height: 48),
          error: (_, __) => const SizedBox(height: 48),
          data: (cats) {
            if (cats.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 48,
              color: AppColors.background,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: cats.length + 1,
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
                  final cat = cats[i - 1];
                  final isSelected = selectedCatId == cat.id;
                  final colorIdx = (i - 1) % _categoryColors.length;
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

              // Filtre par catégorie
              if (selectedCatId != null) {
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

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: produits.length,
                itemBuilder: (_, i) {
                  final p = produits[i];
                  final cIdx = catColorMap[p.categorieId] ?? 0;
                  return _ProduitTile(
                    produit: p,
                    accentColor: _categoryColors[cIdx],
                    bgColor: _categoryBgColors[cIdx],
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
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });
  final LocalProduit produit;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.stockActuel <= 0;
    final effectiveAccent = enRupture ? AppColors.textDisabled : accentColor;
    final effectiveBg = enRupture ? AppColors.surfaceVariant : bgColor;

    return Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: enRupture ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        splashColor: effectiveAccent.withValues(alpha: 0.1),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône produit
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Symbols.inventory_2,
                      size: 18,
                      color: effectiveAccent,
                    ),
                  ),
                  const Spacer(),
                  // Nom
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Prix
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
            // Badge rupture
            if (enRupture)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
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
              ),
            // Badge stock faible
            if (!enRupture &&
                produit.stockActuel <= produit.stockAlerte)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚠',
                    style: TextStyle(fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
