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

  Future<BoutiqueModel> createBoutique(Map<String, dynamic> body) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/boutiques/',
      data: body,
    );
    return BoutiqueModel.fromJson(resp.data!);
  }

  Future<BoutiqueModel> renameBoutique(String boutiqueId, String nom) async {
    final resp = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/boutiques/$boutiqueId',
      data: {'nom': nom},
    );
    return BoutiqueModel.fromJson(resp.data!);
  }
}

final boutiquesApiProvider = Provider<BoutiquesApi>((ref) {
  return BoutiquesApi(ref.watch(dioProvider));
});
