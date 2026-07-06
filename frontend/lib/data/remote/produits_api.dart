import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/produit_model.dart';

class ProduitsApi {
  ProduitsApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<List<ProduitModel>> listProduits(String boutiqueId,
      {int limit = 200, int offset = 0}) async {
    final resp = await _dio.get<List<dynamic>>(
      '$_baseUrl/produits/',
      queryParameters: {
        'boutique_id': boutiqueId,
        'limit': limit,
        'offset': offset,
      },
    );
    return resp.data!
        .map((e) => ProduitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProduitModel> createProduit(ProduitCreateRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/produits/',
      data: request.toJson(),
    );
    return ProduitModel.fromJson(resp.data!);
  }

  Future<ProduitModel> updateProduit(
      String produitId, ProduitUpdateRequest request) async {
    final resp = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/produits/$produitId',
      data: request.toJson(),
    );
    return ProduitModel.fromJson(resp.data!);
  }

  Future<void> deleteProduit(String produitId) async {
    await _dio.delete('$_baseUrl/produits/$produitId');
  }
}

final produitsApiProvider = Provider<ProduitsApi>((ref) {
  return ProduitsApi(ref.watch(dioProvider));
});
