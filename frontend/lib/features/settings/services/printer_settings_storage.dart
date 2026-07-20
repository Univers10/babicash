import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/saved_printer.dart';

/// Persistance de l'imprimante thermique mémorisée.
///
/// Réutilise le mécanisme de stockage déjà présent dans le projet
/// (`flutter_secure_storage`, cf. `lib/core/storage/secure_storage.dart`) —
/// aucune modification du schéma Drift ni du backend.
class PrinterSettingsStorage {
  const PrinterSettingsStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// Clé de stockage (publique pour les tests).
  static const String storageKey = 'babicash_imprimante_bt';

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Charge l'imprimante mémorisée, ou `null` si absente/corrompue.
  Future<SavedPrinter?> load() async {
    try {
      final raw = await _storage.read(
        key: storageKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return SavedPrinter.tryDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Mémorise [printer] comme imprimante par défaut.
  Future<void> save(SavedPrinter printer) => _storage.write(
        key: storageKey,
        value: printer.encode(),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

  /// Oublie l'imprimante mémorisée.
  Future<void> clear() => _storage.delete(
        key: storageKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
}

final printerSettingsStorageProvider = Provider<PrinterSettingsStorage>((ref) {
  return const PrinterSettingsStorage(FlutterSecureStorage());
});
