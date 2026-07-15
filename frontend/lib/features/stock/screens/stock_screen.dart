import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/stock_provider.dart';
import '../widgets/produit_card.dart';
import '../widgets/produit_form_dialog.dart';

// Filtre actif
enum _StockFilter { tous, ruptures, alertes }

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  String _searchQuery = '';
  _StockFilter _filter = _StockFilter.tous;
  String? _selectedCatId;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final stockAsync = ref.watch(stockProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Stock'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Symbols.view_list : Symbols.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
          ),
          IconButton(
            icon: const Icon(Symbols.category),
            onPressed: () => context.push(AppRoutes.categories),
            tooltip: 'Catégories',
          ),
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () {
              ref.invalidate(stockProvider);
              ref.invalidate(categoriesProvider);
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProduitFormDialog(),
        ),
        icon: const Icon(Symbols.add),
        label: const Text('Produit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: stockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Erreur de chargement', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        data: (allProduits) {
          if (allProduits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.inventory_2, size: 64, color: AppColors.textDisabled),
                  const VGap(AppSpacing.lg),
                  Text('Aucun produit',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const VGap(AppSpacing.sm),
                  Text('Ajoutez votre premier produit\npour gérer votre stock',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            );
          }

          // Stats
          final totalProduits = allProduits.length;
          final ruptures = allProduits.where((p) => p.stockActuel <= 0).length;
          final alertes = allProduits
              .where((p) => p.stockActuel > 0 && p.stockActuel <= p.stockAlerte)
              .length;

          // Filtrage
          var produits = allProduits.toList();
          if (_filter == _StockFilter.ruptures) {
            produits = produits.where((p) => p.stockActuel <= 0).toList();
          } else if (_filter == _StockFilter.alertes) {
            produits = produits
                .where((p) => p.stockActuel > 0 && p.stockActuel <= p.stockAlerte)
                .toList();
          }
          if (_selectedCatId != null) {
            produits = produits.where((p) => p.categorieId == _selectedCatId).toList();
          }
          if (_searchQuery.isNotEmpty) {
            produits = produits
                .where((p) => p.nom.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockProvider);
              ref.invalidate(categoriesProvider);
            },
            child: Column(
              children: [
                // ── Stats résumé ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Produits',
                        value: '$totalProduits',
                        color: AppColors.primary,
                        icon: Symbols.inventory_2,
                        isSelected: _filter == _StockFilter.tous,
                        onTap: () => setState(() => _filter = _StockFilter.tous),
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Ruptures',
                        value: '$ruptures',
                        color: AppColors.error,
                        icon: Symbols.warning,
                        isSelected: _filter == _StockFilter.ruptures,
                        onTap: () => setState(() => _filter = _filter == _StockFilter.ruptures
                            ? _StockFilter.tous
                            : _StockFilter.ruptures),
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Alertes',
                        value: '$alertes',
                        color: AppColors.warning,
                        icon: Symbols.notification_important,
                        isSelected: _filter == _StockFilter.alertes,
                        onTap: () => setState(() => _filter = _filter == _StockFilter.alertes
                            ? _StockFilter.tous
                            : _StockFilter.alertes),
                      ),
                    ],
                  ),
                ),

                // ── Barre de recherche ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                      prefixIcon: const Icon(Symbols.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Symbols.close, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // ── Filtre catégories ─────────────────────────────────
                categoriesAsync.when(
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (cats) {
                    if (cats.isEmpty) return const SizedBox.shrink();
                    return Container(
                      height: 44,
                      margin: const EdgeInsets.only(top: 10),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cats.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            final isSelected = _selectedCatId == null;
                            return _CatChip(
                              label: 'Toutes',
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedCatId = null),
                            );
                          }
                          final cat = cats[i - 1];
                          final isSelected = _selectedCatId == cat.id;
                          return _CatChip(
                            label: cat.nom,
                            isSelected: isSelected,
                            onTap: () => setState(() =>
                                _selectedCatId = isSelected ? null : cat.id),
                          );
                        },
                      ),
                    );
                  },
                ),

                // ── Produits (liste ou grille) ─────────────────────────
                const SizedBox(height: 8),
                Expanded(
                  child: produits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Symbols.search_off, size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun résultat',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        )
                      : _isGridView
                          ? _buildGridView(produits)
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
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

  Widget _buildGridView(List produits) {
    final screenW = MediaQuery.of(context).size.width;
    final crossCount = screenW > 900 ? 4 : screenW > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: produits.length,
      itemBuilder: (_, i) {
        final p = produits[i];
        final enRupture = p.stockActuel <= 0;
        final enAlerte = !enRupture && p.stockActuel <= p.stockAlerte;
        Color stockColor = AppColors.success;
        if (enRupture) { stockColor = AppColors.error; }
        else if (enAlerte) { stockColor = AppColors.warning; }

        return Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (_) => ProduitFormDialog(produit: p),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône + badge stock
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Symbols.inventory_2, color: AppColors.primary, size: 18),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (enRupture || enAlerte)
                              Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Icon(
                                  enRupture ? Symbols.warning : Symbols.info,
                                  size: 10,
                                  color: stockColor,
                                ),
                              ),
                            Text(
                              '${p.stockActuel}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: stockColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Nom
                  Text(
                    p.nom,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Prix
                  Text(
                    '${p.prixVenteSuggere.toStringAsFixed(0)} F',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Carte stat ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chip catégorie ───────────────────────────────────────────────────────────

class _CatChip extends StatelessWidget {
  const _CatChip({
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
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
