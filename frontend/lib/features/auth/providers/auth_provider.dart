import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/remote/auth_api.dart';
import 'package:dio/dio.dart';

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
    if (token == null || role == null || nom == null) return null;
    return SessionUser(
      token: token,
      role: role,
      nom: nom,
      boutiqueId: boutiqueId,
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

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearSession();
    state = const AsyncData(null);
  }
}
