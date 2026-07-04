import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/sync_model.dart';

class SyncApi {
  SyncApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<SyncPushResponse> push(SyncPushRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/sync/push',
      data: request.toJson(),
    );
    return SyncPushResponse.fromJson(resp.data!);
  }

  Future<SyncPullResponse> pull(String boutiqueId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/sync/pull',
      queryParameters: {'boutique_id': boutiqueId},
    );
    return SyncPullResponse.fromJson(resp.data!);
  }
}

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.watch(dioProvider));
});
