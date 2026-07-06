import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../../data/local/database.dart';
import '../../../data/remote/categories_api.dart';
import '../../../data/remote/produits_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';

final stockProvider = FutureProvider<List<LocalProduit>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (user == null || boutiqueId == null) return [];

  // Pull backend quand on est en ligne.
  final connectivity = await Connectivity().checkConnectivity();
  if (!connectivity.contains(ConnectivityResult.none)) {
    try {
      final api = ref.watch(produitsApiProvider);
      final produits = await api.listProduits(boutiqueId);
      await db.upsertAllProduits(produits
          .map((p) => LocalProduitsCompanion(
                id: drift.Value(p.id),
                boutiqueId: drift.Value(boutiqueId),
                nom: drift.Value(p.nom),
                prixAchatMoyen: drift.Value(p.prixAchatMoyen),
                prixVenteSuggere: drift.Value(p.prixVenteSuggere),
                stockActuel: drift.Value(p.stockActuel),
                stockAlerte: drift.Value(p.stockAlerte),
                categorieId: drift.Value(p.categorieId),
              ))
          .toList());
    } catch (_) {
      // Fallback silencieux sur le local.
    }
  }

  return db.getProduitsByBoutique(boutiqueId);
});

final categoriesProvider = FutureProvider<List<LocalCategory>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return [];

  final connectivity = await Connectivity().checkConnectivity();
  if (!connectivity.contains(ConnectivityResult.none)) {
    try {
      final api = ref.watch(categoriesApiProvider);
      final categories = await api.listCategories(boutiqueId);
      await db.upsertAllCategories(categories
          .map((c) => LocalCategoriesCompanion(
                id: drift.Value(c.id),
                boutiqueId: drift.Value(boutiqueId),
                nom: drift.Value(c.nom),
              ))
          .toList());
    } catch (_) {
      // Fallback silencieux.
    }
  }

  return db.getCategoriesByBoutique(boutiqueId);
});
