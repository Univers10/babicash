import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/abonnement_model.dart';

class AbonnementsApi {
  AbonnementsApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<AbonnementOut> monPlan() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('$_baseUrl/abonnements/mon-plan');
      return AbonnementOut.fromJson(resp.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<QuotaInfo> quotaBoutique(String boutiqueId) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/abonnements/quota/$boutiqueId',
      );
      return QuotaInfo.fromJson(resp.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AbonnementOut> upgrade(UpgradePlanRequest request) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/abonnements/upgrade',
        data: request.toJson(),
      );
      return AbonnementOut.fromJson(resp.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final abonnementsApiProvider = Provider<AbonnementsApi>((ref) {
  return AbonnementsApi(ref.watch(dioProvider));
});
