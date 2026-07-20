import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kTokenKey = 'babicash_jwt';
const _kRoleKey = 'babicash_role';
const _kBoutiqueIdKey = 'babicash_boutique_id';
const _kNomKey = 'babicash_nom';
const _kEmailKey = 'babicash_email';

// Empreinte locale du PIN (verrouillage hors ligne) — durée de vie = session.
const _kPinHashKey = 'babicash_pin_hash';

// Clés persistantes (survivent à clearSession) : préremplissage des écrans
// de connexion après expiration de session ou déconnexion.
const _kTelephoneKey = 'babicash_telephone';
const _kLastEmailKey = 'babicash_last_email';
const _kLastLoginMethodKey = 'babicash_last_login_method';

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
    String? email,
  }) async {
    await Future.wait([
      _storage.write(key: _kTokenKey, value: token, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.write(key: _kRoleKey, value: role, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.write(key: _kNomKey, value: nom, aOptions: _androidOptions, iOptions: _iosOptions),
      if (boutiqueId != null)
        _storage.write(key: _kBoutiqueIdKey, value: boutiqueId, aOptions: _androidOptions, iOptions: _iosOptions),
      if (email != null)
        _storage.write(key: _kEmailKey, value: email, aOptions: _androidOptions, iOptions: _iosOptions),
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

  Future<String?> getEmail() =>
      _storage.read(key: _kEmailKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Verrouillage hors ligne (empreinte du PIN) ─────────────────────────────

  Future<void> savePinHash(String pinHash) => _storage.write(
      key: _kPinHashKey, value: pinHash, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getPinHash() =>
      _storage.read(key: _kPinHashKey, aOptions: _androidOptions, iOptions: _iosOptions);

  // ── Préremplissage des écrans de connexion (persistant) ────────────────────

  Future<void> saveTelephone(String telephone) => _storage.write(
      key: _kTelephoneKey, value: telephone, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getTelephone() =>
      _storage.read(key: _kTelephoneKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<void> saveLastEmail(String email) => _storage.write(
      key: _kLastEmailKey, value: email, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getLastEmail() =>
      _storage.read(key: _kLastEmailKey, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<void> saveLastLoginMethod(String method) => _storage.write(
      key: _kLastLoginMethodKey, value: method, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<String?> getLastLoginMethod() =>
      _storage.read(key: _kLastLoginMethodKey, aOptions: _androidOptions, iOptions: _iosOptions);

  /// Efface la session courante. Les clés de préremplissage (téléphone,
  /// dernier email, mode de connexion) sont volontairement conservées pour
  /// faciliter la reconnexion ; l'empreinte du PIN est supprimée.
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _kTokenKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kRoleKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kBoutiqueIdKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kNomKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kEmailKey, aOptions: _androidOptions, iOptions: _iosOptions),
      _storage.delete(key: _kPinHashKey, aOptions: _androidOptions, iOptions: _iosOptions),
    ]);
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});
