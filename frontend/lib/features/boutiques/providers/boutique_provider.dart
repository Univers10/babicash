import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/boutique_model.dart';
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

/// Liste des boutiques visibles pour l'utilisateur courant.
/// - OWNER : toutes ses boutiques.
/// - MANAGER : uniquement sa boutique (déjà filtré côté backend).
final mesBoutiquesProvider = FutureProvider<List<BoutiqueModel>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  final api = ref.watch(boutiquesApiProvider);
  return api.listBoutiques();
});

/// Boutique active pour le contexte courant (résumé affiché dans les paramètres).
final boutiqueInfoProvider = FutureProvider<BoutiqueModel?>((ref) async {
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return null;
  final api = ref.watch(boutiquesApiProvider);
  final list = await api.listBoutiques();
  return list.where((b) => b.id == boutiqueId).firstOrNull;
});
