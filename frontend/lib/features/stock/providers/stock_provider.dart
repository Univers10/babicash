import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../features/auth/providers/auth_provider.dart';

final stockProvider = FutureProvider<List<LocalProduit>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return [];
  return db.getProduitsByBoutique(user!.boutiqueId!);
});
