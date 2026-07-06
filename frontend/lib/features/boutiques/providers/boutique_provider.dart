import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/boutiques_api.dart';
import '../../auth/providers/auth_provider.dart';

/// Identifie la boutique active pour le contexte courant.
/// - MANAGER : utilise la boutique_id du token.
/// - OWNER : si le token n'a pas de boutique_id, charge la première boutique
///   de la liste et la persiste en session.
final currentBoutiqueIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  if (user.boutiqueId != null) return user.boutiqueId;

  // Pour un OWNER sans boutique_id, on récupère sa première boutique.
  if (user.isOwner) {
    final api = ref.watch(boutiquesApiProvider);
    final boutiques = await api.listBoutiques();
    if (boutiques.isNotEmpty) return boutiques.first.id;
  }

  return null;
});
