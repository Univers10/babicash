import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/session_model.dart';

class SessionsApi {
  SessionsApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<SessionResumeModel?> sessionActive(String boutiqueId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/sessions/active',
      queryParameters: {'boutique_id': boutiqueId},
    );
    return resp.data == null ? null : SessionResumeModel.fromJson(resp.data!);
  }

  Future<List<SessionModel>> listSessions(
    String boutiqueId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _dio.get<List<dynamic>>(
      '$_baseUrl/sessions/',
      queryParameters: {
        'boutique_id': boutiqueId,
        'limit': limit,
        'offset': offset,
      },
    );
    return resp.data!
        .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SessionModel> ouvrirSession(SessionOuvrirRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/sessions/ouvrir',
      data: request.toJson(),
    );
    return SessionModel.fromJson(resp.data!);
  }

  Future<SessionResumeModel> fermerSession(String id, SessionFermerRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/sessions/$id/fermer',
      data: request.toJson(),
    );
    return SessionResumeModel.fromJson(resp.data!);
  }
}

final sessionsApiProvider = Provider<SessionsApi>((ref) {
  return SessionsApi(ref.watch(dioProvider));
});
