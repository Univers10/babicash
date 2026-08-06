import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/receipt_config.dart';

/// Ancien stockage de la personnalisation du reçu (`flutter_secure_storage`).
///
/// Conservé uniquement pour la **migration unique** vers Drift + backend :
/// [RecuConfigRepository.load] importe cette valeur héritée puis appelle
/// [clear]. Ne plus utiliser pour de nouvelles écritures.
class ReceiptSettingsStorage {
  const ReceiptSettingsStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// Clé de stockage (publique pour les tests).
  static const String storageKey = 'babicash_recu_config';

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Charge la config mémorisée, ou `null` si absente/corrompue.
  Future<ReceiptConfig?> load() async {
    try {
      final raw = await _storage.read(
        key: storageKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return ReceiptConfig.tryDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Mémorise la personnalisation [config] du reçu.
  Future<void> save(ReceiptConfig config) => _storage.write(
        key: storageKey,
        value: config.encode(),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

  /// Réinitialise la personnalisation du reçu.
  Future<void> clear() => _storage.delete(
        key: storageKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
}

final receiptSettingsStorageProvider = Provider<ReceiptSettingsStorage>((ref) {
  return const ReceiptSettingsStorage(FlutterSecureStorage());
});
