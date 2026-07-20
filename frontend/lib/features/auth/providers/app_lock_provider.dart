import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../../data/models/auth_model.dart';
import 'auth_provider.dart';

/// Politique de verrouillage de la caisse — logique pure, testable.
///
/// Exigence de sécurité (caisse partagée) : un gérant connecté par PIN doit
/// ressaisir son PIN si l'app est restée plus de 60 s en arrière-plan.
/// Un propriétaire (email / Google / Apple) n'est jamais verrouillé — ce qui
/// exempte de fait le passage en arrière-plan provoqué par le Custom Tab
/// des flux OAuth (l'utilisateur n'y est pas encore connecté, ou est OWNER).
abstract final class AppLockPolicy {
  /// Délai d'inactivité hors de l'app avant verrouillage.
  static const Duration lockDelay = Duration(seconds: 60);

  /// Détermine si l'écran de verrouillage doit s'afficher au retour au
  /// premier plan.
  ///
  /// - [backgroundedAt] : instant du passage en arrière-plan (null si
  ///   l'app n'était pas passée en arrière-plan) ;
  /// - [now] : instant du retour au premier plan ;
  /// - [user] : session courante (null si déconnecté) ;
  /// - [hasLocalPinHash] : une empreinte locale du PIN existe, la
  ///   vérification hors ligne est donc possible.
  static bool shouldLock({
    required DateTime? backgroundedAt,
    required DateTime now,
    required SessionUser? user,
    required bool hasLocalPinHash,
  }) {
    if (backgroundedAt == null) return false;
    // Seuls les comptes connectés par PIN (gérants) sont concernés.
    if (user == null || !user.isManager) return false;
    // Sans empreinte locale, impossible de vérifier le PIN hors ligne :
    // on ne verrouille pas plutôt que de bloquer l'utilisateur.
    if (!hasLocalPinHash) return false;
    return now.difference(backgroundedAt) > lockDelay;
  }
}

/// `true` quand l'écran de verrouillage doit recouvrir l'app.
final appLockProvider =
    NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);

class AppLockNotifier extends Notifier<bool> {
  DateTime? _backgroundedAt;

  @override
  bool build() {
    // Déconnexion (logout ou session expirée) → le verrouillage n'a plus
    // de sens, l'écran de login prend le relais.
    ref.listen(authStateProvider, (_, next) {
      if (next.valueOrNull == null && state) state = false;
    });
    return false;
  }

  /// À appeler quand l'app passe en arrière-plan.
  void onAppPaused({DateTime? now}) {
    _backgroundedAt = now ?? DateTime.now();
  }

  /// À appeler au retour au premier plan : verrouille si nécessaire.
  Future<void> onAppResumed({DateTime? now}) async {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || !user.isManager) return;

    final pinHash = await ref.read(secureStorageProvider).getPinHash();
    if (AppLockPolicy.shouldLock(
      backgroundedAt: backgroundedAt,
      now: now ?? DateTime.now(),
      user: user,
      hasLocalPinHash: pinHash != null && pinHash.isNotEmpty,
    )) {
      state = true;
    }
  }

  /// Vérifie le PIN saisi contre l'empreinte locale (HORS LIGNE).
  /// Retourne `true` et déverrouille si le PIN est correct.
  Future<bool> unlock(String pin) async {
    final stored = await ref.read(secureStorageProvider).getPinHash();
    if (stored == null || stored.isEmpty) {
      // Empreinte absente (cas limite) : ne pas bloquer l'utilisateur.
      state = false;
      return true;
    }
    if (PinHasher.verify(pin, stored)) {
      state = false;
      return true;
    }
    return false;
  }
}
