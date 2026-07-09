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

    return Column(
      children: [
        // ── Barre de catégories ─────────────────────────────────────────
        categoriesAsync.when(
          loading: () => const SizedBox(height: 48),
          error: (_, __) => const SizedBox(height: 48),
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 48,
              color: AppColors.background,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    final isSelected = selectedCatId == null;
                    return _CategoryChip(
                      label: 'Tout',
                      isSelected: isSelected,
                      onTap: () => ref.read(_selectedCategoryProvider.notifier).state = null,
                    );
                  }
                  final cat = categories[i - 1];
                  final isSelected = selectedCatId == cat.id;
                  return _CategoryChip(
                    label: cat.nom,
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
                itemBuilder: (_, i) => _ProduitTile(
                  produit: produits[i],
                  onTap: () => onProduitTap(produits[i]),
                ),
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
    required this.isSelected,
    required this.onTap,
  });
  final String label;
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
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Palette de couleurs pour les tiles (cycle) — charte BabiCash
const _tileAccents = [
  AppColors.primary,
  AppColors.accent,
  AppColors.primaryLight,
  AppColors.accentDark,
  AppColors.primaryDark,
  AppColors.brown,
  AppColors.success,
  AppColors.warning,
];
const _tileBgs = [
  AppColors.primaryContainer,
  AppColors.accentContainer,
  AppColors.primaryContainer,
  AppColors.accentContainer,
  AppColors.successContainer,
  AppColors.warningContainer,
  AppColors.successContainer,
  AppColors.warningContainer,
];

class _ProduitTile extends StatelessWidget {
  const _ProduitTile({required this.produit, required this.onTap});
  final LocalProduit produit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.stockActuel <= 0;
    final colorIdx = produit.nom.codeUnitAt(0) % _tileAccents.length;
    final accentColor =
        enRupture ? AppColors.textDisabled : _tileAccents[colorIdx];
    final bgColor =
        enRupture ? AppColors.surfaceVariant : _tileBgs[colorIdx];

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: enRupture ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        splashColor: accentColor.withValues(alpha: 0.1),
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
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Symbols.inventory_2,
                      size: 18,
                      color: accentColor,
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
                      color: accentColor,
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
