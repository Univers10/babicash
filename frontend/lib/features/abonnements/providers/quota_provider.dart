import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/abonnement_model.dart';
import '../../../data/remote/abonnements_api.dart';
import '../../auth/providers/auth_provider.dart';

final quotaProvider = FutureProvider.autoDispose<QuotaInfo?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return null;

  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.quotaBoutique(user!.boutiqueId!);
  } on AppException {
    return null;
  }
});

final monPlanProvider = FutureProvider.autoDispose<AbonnementOut?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || !user.isOwner) return null;

  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.monPlan();
  } on AppException {
    return null;
  }
});
