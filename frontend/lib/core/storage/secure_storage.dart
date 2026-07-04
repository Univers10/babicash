import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kTokenKey = 'babicash_jwt';
const _kRoleKey = 'babicash_role';
const _kBoutiqueIdKey = 'babicash_boutique_id';
const _kNomKey = 'babicash_nom';

class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  Future<void> saveSession({
    required String token,
    required String role,
    required String nom,
    String? boutiqueId,
  }) async {
    await Future.wait([
      _storage.write(key: _kTokenKey, value: token, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.write(key: _kRoleKey, value: role, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.write(key: _kNomKey, value: nom, aOptions: _androidOptions, iOptions: _iosOptions),
      if (boutiqueId != null)
        _storage.write(key: _kBoutiqueIdKey, value: boutiqueId, aOptions: _androidOptions, iOptions: _iosOptions),
    ]);
  }

  Future<String?> getToken() =>
      _storage.read(key: _kTokenKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getRole() =>
      _storage.read(key: _kRoleKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getBoutiqueId() =>
      _storage.read(key: _kBoutiqueIdKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getNom() =>
      _storage.read(key: _kNomKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _kTokenKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kRoleKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kBoutiqueIdKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kNomKey, aOptions: _androidOptions, iOptions: _iosOptions),
    ]);
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});
