import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../models/receipt_config.dart';
import 'receipt_settings_storage.dart';
import 'recu_config_api.dart';

/// Source de vérité de la personnalisation du reçu, scindée par boutique.
///
/// Offline-first : la config vit dans Drift (`LocalRecuConfigs`) pour rester
/// disponible sans réseau au moment de la vente. Les modifications locales sont
/// marquées `synced = false` et poussées vers le serveur par le [SyncService] ;
/// le serveur est la source de vérité au `pull` (sauf modification locale en
/// attente, qui a priorité). Réconciliation dernier-écrivain-gagne.
class RecuConfigRepository {
  RecuConfigRepository({
    required AppDatabase db,
    required RecuConfigApi api,
    required ReceiptSettingsStorage legacyStorage,
  })  : _db = db,
        _api = api,
        _legacy = legacyStorage;

  final AppDatabase _db;
  final RecuConfigApi _api;
  final ReceiptSettingsStorage _legacy;

  /// Charge la config locale de [boutiqueId]. Migre une seule fois une
  /// éventuelle config héritée de l'ancien stockage (flutter_secure_storage).
  Future<ReceiptConfig> load(String boutiqueId) async {
    final row = await _db.getRecuConfig(boutiqueId);
    if (row != null) return _fromRow(row);

    final legacy = await _legacy.load();
    if (legacy != null) {
      // Réimporte l'ancienne config comme modification à synchroniser, puis
      // purge le secure storage pour ne migrer qu'une fois.
      await _db.upsertRecuConfig(
        _companion(boutiqueId, legacy, synced: false, updatedAt: DateTime.now()),
      );
      await _legacy.clear();
      return legacy;
    }
    return const ReceiptConfig();
  }

  /// Enregistre [config] localement (`synced = false`) : sera poussée au
  /// prochain cycle de synchronisation.
  Future<void> save(String boutiqueId, ReceiptConfig config) => _db.upsertRecuConfig(
        _companion(boutiqueId, config, synced: false, updatedAt: DateTime.now()),
      );

  /// Pousse la config locale en attente vers le serveur. Retourne 1 si un
  /// envoi a eu lieu, 0 sinon. Peut lever une [AppException] (réseau) —
  /// l'appelant la traite silencieusement et réessaiera.
  Future<int> push(String boutiqueId) async {
    final pending = await _db.getRecuConfigNonSync(boutiqueId);
    if (pending == null) return 0;
    await _api.put(boutiqueId, _fromRow(pending));
    await _db.marquerRecuConfigSync(boutiqueId);
    return 1;
  }

  /// Récupère la config serveur et rafraîchit le cache local — sauf si une
  /// modification locale est en attente (priorité au push).
  Future<void> pull(String boutiqueId) async {
    final local = await _db.getRecuConfig(boutiqueId);
    if (local != null && !local.synced) return; // modif locale à pousser
    final remote = await _api.get(boutiqueId);
    if (remote == null) return; // pas encore de config côté serveur
    await _db.upsertRecuConfig(
      _companion(
        boutiqueId,
        remote.config,
        synced: true,
        updatedAt: remote.updatedAt,
      ),
    );
  }

  static ReceiptConfig _fromRow(LocalRecuConfig r) => ReceiptConfig(
        nomBoutique: r.nomBoutique,
        adresse: r.adresse,
        telephone: r.telephone,
        entete: r.entete,
        piedMessage: r.piedMessage,
        afficherLogo: r.afficherLogo,
        afficherVendeur: r.afficherVendeur,
      );

  static LocalRecuConfigsCompanion _companion(
    String boutiqueId,
    ReceiptConfig c, {
    required bool synced,
    required DateTime updatedAt,
  }) =>
      LocalRecuConfigsCompanion(
        boutiqueId: Value(boutiqueId),
        nomBoutique: Value(c.nomBoutique),
        adresse: Value(c.adresse),
        telephone: Value(c.telephone),
        entete: Value(c.entete),
        piedMessage: Value(c.piedMessage),
        afficherLogo: Value(c.afficherLogo),
        afficherVendeur: Value(c.afficherVendeur),
        synced: Value(synced),
        updatedAt: Value(updatedAt),
      );
}

final recuConfigRepositoryProvider = Provider<RecuConfigRepository>((ref) {
  return RecuConfigRepository(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(recuConfigApiProvider),
    legacyStorage: ref.watch(receiptSettingsStorageProvider),
  );
});
