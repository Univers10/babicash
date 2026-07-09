import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/tier_model.dart';

class TiersApi {
  TiersApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<List<TierModel>> listTiers(
    String boutiqueId, {
    String? typeTiers,
    int limit = 200,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'boutique_id': boutiqueId,
      'limit': limit,
      'offset': offset,
    };
    if (typeTiers != null) params['type_tiers'] = typeTiers;
    final resp = await _dio.get<List<dynamic>>(
      '$_baseUrl/tiers/',
      queryParameters: params,
    );
    return resp.data!
        .map((e) => TierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TierModel> createTier(TierCreateRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/tiers/',
      data: request.toJson(),
    );
    return TierModel.fromJson(resp.data!);
  }

  Future<TierModel> updateTier(String id, TierUpdateRequest request) async {
    final resp = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/tiers/$id',
      data: request.toJson(),
    );
    return TierModel.fromJson(resp.data!);
  }

  Future<TierModel> enregistrerPaiement(String id, PaiementTierRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/tiers/$id/paiement',
      data: request.toJson(),
    );
    return TierModel.fromJson(resp.data!);
  }

  Future<void> deleteTier(String id) async {
    await _dio.delete('$_baseUrl/tiers/$id');
  }
}

final tiersApiProvider = Provider<TiersApi>((ref) {
  return TiersApi(ref.watch(dioProvider));
});
