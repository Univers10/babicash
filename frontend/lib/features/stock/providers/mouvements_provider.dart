import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/sync/sync_service.dart';
import '../domain/stock_calculator.dart';

/// Journal des mouvements de stock de la boutique courante (S3).
/// Stream Drift : toute écriture locale est reflétée immédiatement.
final mouvementsStockProvider =
    StreamProvider<List<LocalMouvementsStockData>>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) {
    yield const [];
    return;
  }
  yield* db.watchMouvementsByBoutique(boutiqueId);
});

/// Nombre de mouvements des dernières 24 h — badge discret dans l'UI (S4).
final mouvementsRecentsCountProvider = Provider<int>((ref) {
  final mouvements = ref.watch(mouvementsStockProvider).value ?? const [];
  final limite = DateTime.now().subtract(const Duration(hours: 24));
  return mouvements.where((m) => m.dateMouvement.isAfter(limite)).length;
});

/// Extrait l'identifiant utilisateur (`sub`) du JWT, sans vérification —
/// uniquement pour tracer l'auteur localement (le serveur fait foi).
String? extraireUserIdDuJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    final sub = payload['sub'];
    return sub is String ? sub : null;
  } catch (_) {
    return null;
  }
}

class MouvementsStockNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Enregistre un mouvement (entrée ou sortie) : écriture Drift d'abord
  /// (`synced = false`) avec recalcul du stock, puis tentative de sync.
  Future<void> enregistrerMouvement({
    required LocalProduit produit,
    required String typeMouvement,
    required int quantite,
    required String motif,
  }) async {
    final user = ref.read(authStateProvider).value;
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (user == null || boutiqueId == null) {
      throw Exception('Session ou boutique introuvable');
    }

    final nouveauStock = recalculerStock(
      stockActuel: produit.stockActuel,
      typeMouvement: typeMouvement,
      quantite: quantite,
    );

    final db = ref.read(appDatabaseProvider);
    await db.appliquerMouvementStock(
      mouvement: LocalMouvementsStockCompanion(
        id: drift.Value(const Uuid().v4()),
        boutiqueId: drift.Value(boutiqueId),
        produitId: drift.Value(produit.id),
        produitNom: drift.Value(produit.nom),
        typeMouvement: drift.Value(typeMouvement),
        quantite: drift.Value(quantite),
        motif: drift.Value(motif),
        auteurId: drift.Value(extraireUserIdDuJwt(user.token)),
        auteurNom: drift.Value(user.nom),
        dateMouvement: drift.Value(DateTime.now()),
        synced: const drift.Value(false),
      ),
      produitId: produit.id,
      nouveauStock: nouveauStock,
    );

    // Sync best-effort : silencieuse hors ligne, retentée plus tard.
    try {
      await ref.read(syncServiceProvider).pushPending();
    } catch (_) {
      // Le mouvement reste `synced = false` et sera repoussé.
    }
  }
}

final mouvementsCrudProvider =
    AsyncNotifierProvider<MouvementsStockNotifier, void>(
        MouvementsStockNotifier.new);
