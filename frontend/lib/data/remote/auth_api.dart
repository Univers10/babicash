import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/auth_model.dart';

class AuthApi {
  AuthApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  Future<TokenResponse> login(LoginRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/auth/login',
      data: request.toJson(),
    );
    return TokenResponse.fromJson(resp.data!);
  }

  Future<TokenResponse> loginPin(LoginPinRequest request) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/auth/login-pin',
      data: request.toJson(),
    );
    return TokenResponse.fromJson(resp.data!);
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});
