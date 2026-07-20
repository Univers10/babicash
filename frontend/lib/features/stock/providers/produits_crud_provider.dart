import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../data/local/database.dart';
import '../../../data/models/produit_model.dart';
import '../../../data/remote/produits_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import 'stock_provider.dart';

class ProduitsCrudNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createProduit({
    required String nom,
    String? categorieId,
    required double prixAchat,
    required double prixVente,
    required int stock,
    required int stockAlerte,
  }) async {
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) throw Exception('Aucune boutique sélectionnée');

    // Crée d'abord sur le backend pour obtenir l'ID officiel.
    final produit = await ref.read(produitsApiProvider).createProduit(
      ProduitCreateRequest(
        boutiqueId: boutiqueId,
        categorieId: categorieId,
        nom: nom,
        prixAchatMoyen: prixAchat,
        prixVenteSuggere: prixVente,
        stockActuel: stock,
        stockAlerte: stockAlerte,
      ),
    );

    // Sauvegarde locale avec le même ID.
    await ref.read(appDatabaseProvider).upsertProduit(LocalProduitsCompanion(
      id: drift.Value(produit.id),
      boutiqueId: drift.Value(produit.boutiqueId),
      nom: drift.Value(produit.nom),
      prixAchatMoyen: drift.Value(produit.prixAchatMoyen),
      prixVenteSuggere: drift.Value(produit.prixVenteSuggere),
      stockActuel: drift.Value(produit.stockActuel),
      stockAlerte: drift.Value(produit.stockAlerte),
      categorieId: drift.Value(produit.categorieId),
    ));

    ref.invalidate(stockProvider);
  }

  /// [categorieId] est TOUJOURS appliqué tel quel : `null` signifie
  /// « Sans catégorie » (et non « ne pas modifier »). Le PATCH backend
  /// utilise `exclude_unset`, mais `categorie_id` étant toujours présent
  /// dans le JSON, la valeur envoyée (y compris `null`) fait foi.
  Future<void> updateProduit({
    required String id,
    required String? categorieId,
    String? nom,
    double? prixAchat,
    double? prixVente,
    int? stock,
    int? stockAlerte,
  }) async {
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) throw Exception('Aucune boutique sélectionnée');

    await ref.read(produitsApiProvider).updateProduit(
      id,
      ProduitUpdateRequest(
        categorieId: categorieId,
        nom: nom,
        prixAchatMoyen: prixAchat,
        prixVenteSuggere: prixVente,
        stockActuel: stock,
        stockAlerte: stockAlerte,
      ),
    );

    final db = ref.read(appDatabaseProvider);
    final existing = await (db.select(db.localProduits)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return;

    await db.upsertProduit(LocalProduitsCompanion(
      id: drift.Value(id),
      boutiqueId: drift.Value(boutiqueId),
      nom: drift.Value(nom ?? existing.nom),
      prixAchatMoyen: drift.Value(prixAchat ?? existing.prixAchatMoyen),
      prixVenteSuggere: drift.Value(prixVente ?? existing.prixVenteSuggere),
      stockActuel: drift.Value(stock ?? existing.stockActuel),
      stockAlerte: drift.Value(stockAlerte ?? existing.stockAlerte),
      categorieId: drift.Value(categorieId),
    ));

    ref.invalidate(stockProvider);
  }

  Future<void> deleteProduit(String id) async {
    await ref.read(produitsApiProvider).deleteProduit(id);
    final db = ref.read(appDatabaseProvider);
    await (db.delete(db.localProduits)..where((p) => p.id.equals(id))).go();
    ref.invalidate(stockProvider);
  }
}

final produitsCrudProvider =
    AsyncNotifierProvider<ProduitsCrudNotifier, void>(ProduitsCrudNotifier.new);
