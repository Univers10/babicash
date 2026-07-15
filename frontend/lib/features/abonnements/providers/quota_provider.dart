import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/abonnement_model.dart';
import '../../../data/remote/abonnements_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../boutiques/providers/boutique_provider.dart';

final quotaProvider = FutureProvider.autoDispose<QuotaInfo?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (user == null || boutiqueId == null) return null;

  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.quotaBoutique(boutiqueId);
  } on DioException catch (e) {
    final appEx = mapDioError(e);
    if (appEx is QuotaException || appEx is ForbiddenException) {
      rethrow;
    }
    return null;
  } on AppException catch (e) {
    if (e is QuotaException || e is ForbiddenException) {
      rethrow;
    }
    return null;
  }
});

final monPlanProvider = FutureProvider.autoDispose<AbonnementOut?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || !user.isOwner) return null;

  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.monPlan();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) return null;
    return null;
  } on AppException {
    return null;
  } catch (_) {
    return null;
  }
});
