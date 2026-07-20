import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../../data/local/database.dart';
import '../../../data/remote/categories_api.dart';
import '../../../data/remote/produits_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/sync/sync_service.dart';
import '../../../shared/utils/categorie_utils.dart';

/// Produits de la boutique courante — stream Drift (S1) : l'écran stock
/// reflète l'état local en temps réel (ventes, mouvements, sync).
/// Un rafraîchissement réseau best-effort est déclenché à chaque (re)création
/// du provider (entrée sur l'écran, invalidation, pull-to-refresh).
final stockProvider = StreamProvider<List<LocalProduit>>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (user == null || boutiqueId == null) {
    yield const [];
    return;
  }

  // Pull backend en arrière-plan : le stream Drift propagera les upserts.
  final api = ref.read(produitsApiProvider);
  final syncService = ref.read(syncServiceProvider);
  unawaited(_rafraichirProduits(api, db, syncService, boutiqueId));

  yield* db.watchProduitsByBoutique(boutiqueId);
});

Future<void> _rafraichirProduits(
  ProduitsApi api,
  AppDatabase db,
  SyncService syncService,
  String boutiqueId,
) async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity.contains(ConnectivityResult.none)) return;
  try {
    // Pousser d'abord les écritures locales en attente (mouvements, ventes…)
    // pour ne pas écraser un stock local recalculé mais pas encore synchronisé.
    await syncService.pushPending();
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

  // Tri alphabétique (insensible à la casse et aux accents) appliqué à la
  // source : tous les affichages (dropdown, filtres, écran catégories)
  // héritent du même ordre.
  return trierCategories(await db.getCategoriesByBoutique(boutiqueId));
});
