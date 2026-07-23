import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/boutique_model.dart';

class BoutiquesApi {
  BoutiquesApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<List<BoutiqueModel>> listBoutiques() async {
    final resp = await _dio.get<List<dynamic>>('$_baseUrl/boutiques/');
    return resp.data!
        .map((e) => BoutiqueModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BoutiqueModel> createBoutique({
    required String nom,
    String? adresse,
    String? telephone,
    String? typeCommerce,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/boutiques/',
      data: {
        'nom': nom,
        if (adresse != null && adresse.isNotEmpty) 'adresse': adresse,
        if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
        if (typeCommerce != null && typeCommerce.isNotEmpty) 'type_commerce': typeCommerce,
      },
    );
    return BoutiqueModel.fromJson(resp.data!);
  }

  /// [logoUrl] : `null` = ne pas modifier · `''` = retirer le logo ·
  /// une URL = (re)définir le logo.
  Future<BoutiqueModel> updateBoutique(
    String boutiqueId, {
    String? nom,
    String? adresse,
    String? telephone,
    String? typeCommerce,
    String? logoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (nom != null) data['nom'] = nom;
    if (adresse != null) data['adresse'] = adresse;
    if (telephone != null) data['telephone'] = telephone;
    if (typeCommerce != null) data['type_commerce'] = typeCommerce;
    if (logoUrl != null) data['logo_url'] = logoUrl;
    final resp = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/boutiques/$boutiqueId',
      data: data,
    );
    return BoutiqueModel.fromJson(resp.data!);
  }
}

final boutiquesApiProvider = Provider<BoutiquesApi>((ref) {
  return BoutiquesApi(ref.watch(dioProvider));
});
