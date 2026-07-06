import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/categories_crud_provider.dart';
import '../providers/stock_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Catégories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategorieDialog(context, ref),
        child: const Icon(Symbols.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (categories) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const VGap(AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = categories[i];
            return ListTile(
              title: Text(c.nom, style: AppTextStyles.bodyLarge),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Symbols.edit, size: 20),
                    onPressed: () => _showCategorieDialog(context, ref, categorie: c),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.delete, size: 20),
                    onPressed: () => _deleteCategorie(context, ref, c.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCategorieDialog(BuildContext context, WidgetRef ref,
      {LocalCategory? categorie}) {
    final controller = TextEditingController(text: categorie?.nom ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(categorie == null ? 'Nouvelle catégorie' : 'Modifier catégorie'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nom'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
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
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: Text(categorie == null ? 'Créer' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteCategorie(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(categoriesCrudProvider.notifier).deleteCategorie(id);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
