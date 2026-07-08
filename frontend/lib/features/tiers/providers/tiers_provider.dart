import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/remote/tiers_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';

final tiersTypeProvider = StateProvider<String>((ref) => 'CLIENT');

/// Pull tiers depuis le backend, met à jour le cache Drift, retourne le cache local.
/// En offline, retourne directement le cache local.
final tiersProvider = FutureProvider.family<List<LocalTier>, String>(
  (ref, type) async {
    final db = ref.watch(appDatabaseProvider);
    final user = ref.watch(authStateProvider).value;
    final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
    // ignore: avoid_print
    print('[tiersProvider] user=$user boutiqueId=$boutiqueId type=$type');
    if (user == null || boutiqueId == null) return [];

    final connectivity = await Connectivity().checkConnectivity();
    // ignore: avoid_print
    print('[tiersProvider] connectivity=$connectivity');
    if (!connectivity.contains(ConnectivityResult.none)) {
      try {
        final api = ref.watch(tiersApiProvider);
        final tiers = await api.listTiers(boutiqueId, typeTiers: type);
        // ignore: avoid_print
        print('[tiersProvider] API retourne ${tiers.length} tiers');
        await db.batch((b) {
          b.insertAllOnConflictUpdate(
            db.localTiers,
            tiers.map((t) => LocalTiersCompanion(
              id: drift.Value(t.id),
              boutiqueId: drift.Value(t.boutiqueId),
              nom: drift.Value(t.nom),
              telephone: drift.Value(t.telephone),
              typeTiers: drift.Value(t.typeTiers),
              soldeDu: drift.Value(t.soldeDu),
              synced: const drift.Value(true),
            )).toList(),
          );
        });
      } catch (e) {
        // ignore: avoid_print
        print('[tiersProvider] ERREUR API: $e');
      }
    }

    final local = await db.getTiersByBoutique(boutiqueId, type: type);
    // ignore: avoid_print
    print('[tiersProvider] DB locale retourne ${local.length} tiers');
    return local;
  },
);

final clientsProvider = FutureProvider<List<LocalTier>>((ref) async {
  return ref.watch(tiersProvider('CLIENT').future);
});
