import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/receipt_config.dart';

/// Persistance de la personnalisation du reçu.
///
/// Réutilise le mécanisme de stockage déjà présent dans le projet
/// (`flutter_secure_storage`, cf. [PrinterSettingsStorage]) — aucune
/// modification du schéma Drift ni du backend. La config est disponible
/// hors-ligne : le reçu s'imprime sans appel réseau.
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
