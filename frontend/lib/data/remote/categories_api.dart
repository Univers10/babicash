import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/produit_model.dart';

class CategoriesApi {
  CategoriesApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<List<CategorieModel>> listCategories(String boutiqueId) async {
    final resp = await _dio.get<List<dynamic>>(
      '$_baseUrl/categories/',
      queryParameters: {'boutique_id': boutiqueId},
    );
    return resp.data!
        .map((e) => CategorieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategorieModel> createCategorie(CategorieCreateRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/categories/',
      data: request.toJson(),
    );
    return CategorieModel.fromJson(resp.data!);
  }

  Future<CategorieModel> updateCategorie(
      String categorieId, CategorieUpdateRequest request) async {
    final resp = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/categories/$categorieId',
      data: request.toJson(),
    );
    return CategorieModel.fromJson(resp.data!);
  }

  Future<void> deleteCategorie(String categorieId) async {
    await _dio.delete('$_baseUrl/categories/$categorieId');
  }
}

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(dioProvider));
});
