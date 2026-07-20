import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/config/oauth_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../../data/local/database.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/remote/auth_api.dart';
import 'package:dio/dio.dart';

// ── Mode de connexion ─────────────────────────────────────────────────────────

/// Valeurs persistées dans le secure storage pour savoir comment
/// l'utilisateur s'est connecté la dernière fois.
abstract final class LoginMethod {
  static const pin = 'pin';
  static const email = 'email';
}

/// Renseigné quand le backend répond 401 (session expirée) : contient le
/// mode de connexion de l'utilisateur éjecté ([LoginMethod.pin] ou
/// [LoginMethod.email]) pour rediriger vers le bon écran de reconnexion.
/// Remis à null après un login réussi.
final sessionExpiredProvider = StateProvider<String?>((ref) => null);

// ── État de session courante ──────────────────────────────────────────────────

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, SessionUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<SessionUser?> {
  @override
  Future<SessionUser?> build() async {
    final storage = ref.read(secureStorageProvider);
    if (!await storage.hasSession()) return null;
    final token = await storage.getToken();
    final role = await storage.getRole();
    final nom = await storage.getNom();
    final boutiqueId = await storage.getBoutiqueId();
    final email = await storage.getEmail();
    if (token == null || role == null || nom == null) return null;
    return SessionUser(
      token: token,
      role: role,
      nom: nom,
      boutiqueId: boutiqueId,
      email: email,
    );
  }

  Future<void> loginEmail(String email, String motDePasse) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    try {
      final resp = await api.login(
        LoginRequest(email: email, motDePasse: motDePasse),
      );
      await storage.saveSession(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      );
      await storage.saveLastLoginMethod(LoginMethod.email);
      await storage.saveLastEmail(email);
      _clearSessionExpired();
      state = AsyncData(SessionUser(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      ));
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(const UnknownException(), StackTrace.current);
    }
  }

  Future<void> loginPin(String telephone, String codePin) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    try {
      final resp = await api.loginPin(
        LoginPinRequest(telephone: telephone, codePin: codePin),
      );
      await storage.saveSession(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      );
      // Artefacts du login PIN : téléphone (préremplissage après expiration)
      // et empreinte du PIN (vérification hors ligne du verrouillage).
      await storage.saveTelephone(telephone);
      await storage.savePinHash(PinHasher.hash(codePin));
      await storage.saveLastLoginMethod(LoginMethod.pin);
      _clearSessionExpired();
      state = AsyncData(SessionUser(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      ));
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(const UnknownException(), StackTrace.current);
    }
  }

  Future<void> loginId(String idProprietaire, String motDePasse) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    try {
      final resp = await api.loginId(
        LoginIdRequest(idProprietaire: idProprietaire, motDePasse: motDePasse),
      );
      await storage.saveSession(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      );
      await storage.saveLastLoginMethod(LoginMethod.email);
      _clearSessionExpired();
      state = AsyncData(SessionUser(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      ));
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(const UnknownException(), StackTrace.current);
    }
  }

  Future<void> register(
    String nom,
    String email,
    String motDePasse,
    String? telephone,
  ) async {
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    try {
      final resp = await api.register(
        RegisterRequest(
          nom: nom,
          email: email,
          motDePasse: motDePasse,
          telephone: telephone,
        ),
      );
      await storage.saveSession(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      );
      await storage.saveLastLoginMethod(LoginMethod.email);
      await storage.saveLastEmail(email);
      _clearSessionExpired();
      state = AsyncData(SessionUser(
        token: resp.accessToken,
        role: resp.role,
        nom: resp.nom,
        boutiqueId: resp.boutiqueId,
      ));
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(const UnknownException(), StackTrace.current);
    }
  }

  /// Sauvegarde la session et bascule l'état après un login réussi.
  Future<void> _onLoginSuccess(TokenResponse resp) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveSession(
      token: resp.accessToken,
      role: resp.role,
      nom: resp.nom,
      boutiqueId: resp.boutiqueId,
      email: resp.email,
    );
    await storage.saveLastLoginMethod(LoginMethod.email);
    if (resp.email != null && resp.email!.isNotEmpty) {
      await storage.saveLastEmail(resp.email!);
    }
    _clearSessionExpired();
    state = AsyncData(SessionUser(
      token: resp.accessToken,
      role: resp.role,
      nom: resp.nom,
      boutiqueId: resp.boutiqueId,
      email: resp.email,
    ));
  }

  void _clearSessionExpired() {
    ref.read(sessionExpiredProvider.notifier).state = null;
  }

  /// Appelé par l'intercepteur Dio quand le backend répond 401 : la session
  /// est expirée. Bascule l'état à « déconnecté » et mémorise le mode de
  /// connexion pour que le routeur redirige vers le bon écran (PIN prérempli
  /// pour un gérant, email pour un propriétaire). La base locale n'est PAS
  /// effacée : l'utilisateur retrouve ses données après reconnexion.
  Future<void> onSessionExpired() async {
    final current = state.valueOrNull;
    // 401 d'une tentative de login (mauvais identifiants) : ne rien faire.
    if (current == null) return;
    final storage = ref.read(secureStorageProvider);
    final method = await storage.getLastLoginMethod();
    ref.read(sessionExpiredProvider.notifier).state =
        method ?? (current.isManager ? LoginMethod.pin : LoginMethod.email);
    // Le token est déjà effacé par l'intercepteur ; on s'assure que le
    // reste de la session l'est aussi (idempotent).
    await storage.clearSession();
    state = const AsyncData(null);
  }

  Future<void> loginWithGoogle() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    try {
      final google = GoogleSignIn(
        scopes: const ['email'],
        serverClientId: OAuthConfig.googleServerClientId,
      );
      final account = await google.signIn();
      if (account == null) {
        // Annulé par l'utilisateur : pas une erreur
        state = AsyncData(previous);
        return;
      }
      final idToken = (await account.authentication).idToken;
      if (idToken == null) {
        state = AsyncError(
          const UnknownException('Google n\'a pas fourni de token.'),
          StackTrace.current,
        );
        return;
      }
      final resp = await api.loginGoogle(GoogleTokenRequest(idToken: idToken));
      await _onLoginSuccess(resp);
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(
        const UnknownException('Connexion Google impossible.'),
        StackTrace.current,
      );
    }
  }

  Future<void> loginWithApple() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    final api = ref.read(authApiProvider);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: OAuthConfig.appleServiceId,
          redirectUri: OAuthConfig.appleRedirectUri,
        ),
      );
      final identityToken = credential.identityToken;
      if (identityToken == null) {
        state = AsyncError(
          const UnknownException('Apple n\'a pas fourni de token.'),
          StackTrace.current,
        );
        return;
      }
      // Apple ne fournit le nom qu'à la toute première autorisation.
      final nom = [credential.givenName, credential.familyName]
          .whereType<String>()
          .join(' ')
          .trim();
      final resp = await api.loginApple(AppleTokenRequest(
        identityToken: identityToken,
        nom: nom.isEmpty ? null : nom,
      ));
      await _onLoginSuccess(resp);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = AsyncData(previous);
        return;
      }
      state = AsyncError(
        const UnknownException('Connexion Apple impossible.'),
        StackTrace.current,
      );
    } on DioException catch (e) {
      state = AsyncError(mapDioError(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(
        const UnknownException('Connexion Apple impossible.'),
        StackTrace.current,
      );
    }
  }

  Future<void> logout() async {
    // Effacer la base locale avant de déconnecter
    try {
      final db = ref.read(appDatabaseProvider);
      await db.delete(db.localLignesVente).go();
      await db.delete(db.localVentes).go();
      await db.delete(db.localProduits).go();
      await db.delete(db.localCategories).go();
      await db.delete(db.localDepenses).go();
      await db.delete(db.localSessions).go();
      await db.delete(db.localTiers).go();
      await db.delete(db.localMouvementsStock).go();
    } catch (_) {
      // Ignorer les erreurs de nettoyage
    }
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Pas de session Google active : rien à faire
    }
    await ref.read(secureStorageProvider).clearSession();
    _clearSessionExpired();
    state = const AsyncData(null);
  }

  /// Met à jour le nom affiché après modification du profil.
  Future<void> updateNom(String newNom) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final storage = ref.read(secureStorageProvider);
    await storage.saveSession(
      token: current.token,
      role: current.role,
      nom: newNom,
      boutiqueId: current.boutiqueId,
    );
    state = AsyncData(current.copyWith(nom: newNom));
  }
}
