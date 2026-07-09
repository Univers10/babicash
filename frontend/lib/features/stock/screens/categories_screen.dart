import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/categories_crud_provider.dart';
import '../providers/stock_provider.dart';

// Palette de couleurs pour les cartes catégories (style Odoo POS)
const _catColors = [
  Color(0xFF1B6B2F),
  Color(0xFFE8A838),
  Color(0xFF2196F3),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFFFF5722),
  Color(0xFF00BCD4),
  Color(0xFF795548),
  Color(0xFF607D8B),
  Color(0xFF4CAF50),
];

const _catIcons = [
  Symbols.local_drink,
  Symbols.spa,
  Symbols.restaurant,
  Symbols.cookie,
  Symbols.free_breakfast,
  Symbols.phone_android,
  Symbols.edit_note,
  Symbols.cleaning_services,
  Symbols.shopping_bag,
  Symbols.category,
];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final stockAsync = ref.watch(stockProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Catégories'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => ref.invalidate(categoriesProvider),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorieDialog(context, ref),
        icon: const Icon(Symbols.add),
        label: const Text('Nouvelle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Erreur : $e', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.category, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune catégorie',
                    style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre première catégorie\npour organiser vos produits',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }

          // Compter les produits par catégorie
          final produits = stockAsync.valueOrNull ?? [];
          final countMap = <String, int>{};
          for (final p in produits) {
            if (p.categorieId != null) {
              countMap[p.categorieId!] = (countMap[p.categorieId!] ?? 0) + 1;
            }
          }

          final screenW = MediaQuery.of(context).size.width;
          final crossCount = screenW > 900 ? 4 : screenW > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final c = categories[i];
              final colorIdx = i % _catColors.length;
              final color = _catColors[colorIdx];
              final icon = _catIcons[colorIdx];
              final count = countMap[c.id] ?? 0;

              return _CategoryCard(
                categorie: c,
                color: color,
                icon: icon,
                productCount: count,
                onEdit: () => _showCategorieDialog(context, ref, categorie: c),
                onDelete: () => _deleteCategorie(context, ref, c.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategorieDialog(BuildContext context, WidgetRef ref,
      {LocalCategory? categorie}) {
    final controller = TextEditingController(text: categorie?.nom ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              categorie == null ? Symbols.add_circle : Symbols.edit,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(categorie == null ? 'Nouvelle catégorie' : 'Modifier catégorie'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nom de la catégorie',
            hintText: 'Ex: Boissons, Alimentaire...',
            prefixIcon: const Icon(Symbols.label),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: Icon(categorie == null ? Symbols.add : Symbols.check),
            onPressed: () async {
              final nom = controller.text.trim();
              if (nom.isEmpty) return;
              final notifier = ref.read(categoriesCrudProvider.notifier);
              try {
                if (categorie == null) {
                  await notifier.createCategorie(nom);
                } else {
                  await notifier.updateCategorie(categorie.id, nom);
                }
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text(_extractErrorMessage(e)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            label: Text(categorie == null ? 'Créer' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteCategorie(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Symbols.warning, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Supprimer ?'),
          ],
        ),
        content: const Text(
          'Cette catégorie sera supprimée définitivement.\nLes produits associés ne seront pas supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: const Icon(Symbols.delete),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                await ref.read(categoriesCrudProvider.notifier).deleteCategorie(id);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              } catch (e) {
                if (dialogCtx.mounted) {
                  final msg = _extractErrorMessage(e);
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _extractErrorMessage(Object e) {
  if (e is DioException && e.response?.data is Map) {
    final detail = (e.response!.data as Map)['detail'];
    if (detail is String) return detail;
  }
  return 'Erreur : $e';
}

// ── Carte catégorie (style Odoo POS) ─────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.categorie,
    required this.color,
    required this.icon,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });
  final LocalCategory categorie;
  final Color color;
  final IconData icon;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24,
        child: Stack(
          children: [
            // Icône décorative en fond
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                icon,
                size: 64,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne supérieure : icône + menu
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 20, color: Colors.white),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(Symbols.more_vert, color: Colors.white.withValues(alpha: 0.8), size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (v) {
                          if (v == 'edit') onEdit();
                          if (v == 'delete') onDelete();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                          const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Nom
                  Text(
                    categorie.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Nombre de produits
                  Text(
                    '$productCount produit${productCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
