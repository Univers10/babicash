import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/providers/auth_provider.dart';

final dashboardGranulariteProvider = StateProvider<String>((_) => 'mois');

final dashboardConsolideProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, granularite) async {
    final user = ref.watch(authStateProvider).value;
    if (user == null || !user.isOwner) return null;
    final dio = ref.watch(dioProvider);
    try {
      final resp = await dio.get(
        '/dashboard/consolide',
        queryParameters: {'granularite': granularite},
      );
      return resp.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  },
);
