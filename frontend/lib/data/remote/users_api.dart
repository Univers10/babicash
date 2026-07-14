import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UsersApi {
  const UsersApi(this._dio);
  final Dio _dio;

  // ── Profil personnel ────────────────────────────────────────────────────────

  Future<UserProfile> getMyProfile() async {
    final resp = await _dio.get<Map<String, dynamic>>('/users/me');
    return UserProfile.fromJson(resp.data!);
  }

  Future<UserProfile> updateMyProfile({
    String? nom,
    String? telephone,
  }) async {
    final data = <String, dynamic>{};
    if (nom != null) data['nom'] = nom;
    if (telephone != null) data['telephone'] = telephone;
    final resp = await _dio.patch<Map<String, dynamic>>('/users/me', data: data);
    return UserProfile.fromJson(resp.data!);
  }

  Future<void> changePin(String codePin) async {
    await _dio.put('/users/me/pin', data: {'code_pin': codePin});
  }

  // ── Gestion équipe ──────────────────────────────────────────────────────────

  /// [boutiqueId] optionnel : utilisé par OWNER. MANAGER utilise son propre boutique du token.
  Future<List<UserProfile>> listUtilisateurs({String? boutiqueId}) async {
    final resp = await _dio.get<List<dynamic>>(
      '/users/',
      queryParameters: boutiqueId != null ? {'boutique_id': boutiqueId} : null,
    );
    return resp.data!
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserProfile> createUtilisateur({
    required String nom,
    required String telephone,
    required String codePin,
    String? email,
    String? boutiqueId,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/users/',
      data: {
        'nom': nom,
        'telephone': telephone,
        'code_pin': codePin,
        'role': 'MANAGER',
        if (email != null && email.isNotEmpty) 'email': email,
        if (boutiqueId != null) 'boutique_id': boutiqueId,
      },
    );
    return UserProfile.fromJson(resp.data!);
  }

  Future<UserProfile> updateUtilisateur(
    String userId, {
    String? nom,
    String? telephone,
    String? codePin,
  }) async {
    final data = <String, dynamic>{};
    if (nom != null) data['nom'] = nom;
    if (telephone != null) data['telephone'] = telephone;
    if (codePin != null) data['code_pin'] = codePin;
    final resp = await _dio.patch<Map<String, dynamic>>(
      '/users/$userId',
      data: data,
    );
    return UserProfile.fromJson(resp.data!);
  }

  Future<void> deleteUtilisateur(String userId) async {
    await _dio.delete('/users/$userId');
  }
}

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(dioProvider)),
);
