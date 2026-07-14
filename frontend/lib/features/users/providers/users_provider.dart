import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/remote/users_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';

/// Profil de l'utilisateur connecté (GET /users/me).
final myProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  try {
    return await ref.watch(usersApiProvider).getMyProfile();
  } catch (_) {
    return null;
  }
});

/// Liste de tous les utilisateurs de la boutique.
final utilisateursProvider = FutureProvider<List<UserProfile>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (user == null || boutiqueId == null) return [];
  try {
    // OWNER passe boutique_id en query param; MANAGER l'obtient depuis son token
    final currentUser = user;
    return await ref.watch(usersApiProvider).listUtilisateurs(
          boutiqueId: currentUser.isOwner ? boutiqueId : null,
        );
  } catch (_) {
    return [];
  }
});
