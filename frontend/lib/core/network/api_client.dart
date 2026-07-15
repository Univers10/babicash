import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage.dart';
import 'cert_pinning.dart';

const String _baseUrl = 'https://babicash.ecomotionafricaci.com';
// Pour dev local : 'http://192.168.1.29:8000'
// Pour émulateur Android : 'http://10.0.2.2:8000'

class ApiClient {
  ApiClient._();

  static Dio create(SecureStorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Certificate pinning (désactivé en debug pour le dev local)
    assert(() {
      // En debug, on n'applique pas le pinning pour permettre le dev local
      return true;
    }());
    dio.interceptors.add(BabiCashCertificatePinning.createPinner());

    // Intercepteur d'authentification JWT
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 → session expirée, on efface le token
          if (error.response?.statusCode == 401) {
            await storage.clearSession();
          }
          handler.next(error);
        },
      ),
    );

    // Logger (uniquement en debug)
    assert(() {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
      );
      return true;
    }());

    return dio;
  }
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient.create(storage);
});
