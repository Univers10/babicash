import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../data/local/database.dart';
import '../../../data/models/produit_model.dart';
import '../../../data/remote/categories_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import 'stock_provider.dart';

class CategoriesCrudNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCategorie(String nom) async {
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) throw Exception('Aucune boutique sélectionnée');

    final categorie = await ref.read(categoriesApiProvider).createCategorie(
      CategorieCreateRequest(boutiqueId: boutiqueId, nom: nom),
    );
    await ref.read(appDatabaseProvider).upsertAllCategories([
      LocalCategoriesCompanion(
        id: drift.Value(categorie.id),
        boutiqueId: drift.Value(boutiqueId),
        nom: drift.Value(categorie.nom),
      ),
    ]);
    ref.invalidate(categoriesProvider);
  }

  Future<void> updateCategorie(String id, String nom) async {
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) throw Exception('Aucune boutique sélectionnée');

    await ref.read(categoriesApiProvider).updateCategorie(
      id,
      CategorieUpdateRequest(nom: nom),
    );
    await ref.read(appDatabaseProvider).upsertAllCategories([
      LocalCategoriesCompanion(
        id: drift.Value(id),
        boutiqueId: drift.Value(boutiqueId),
        nom: drift.Value(nom),
      ),
    ]);
    ref.invalidate(categoriesProvider);
  }

  Future<void> deleteCategorie(String id) async {
    await ref.read(categoriesApiProvider).deleteCategorie(id);
    final db = ref.read(appDatabaseProvider);
    await (db.delete(db.localCategories)..where((c) => c.id.equals(id))).go();
    ref.invalidate(categoriesProvider);
  }
}

final categoriesCrudProvider =
    AsyncNotifierProvider<CategoriesCrudNotifier, void>(CategoriesCrudNotifier.new);
