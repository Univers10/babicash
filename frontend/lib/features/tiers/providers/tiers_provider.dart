import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../features/auth/providers/auth_provider.dart';

final tiersTypeProvider = StateProvider<String>((ref) => 'CLIENT');

final tiersProvider = FutureProvider.family<List<LocalTier>, String>((ref, type) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return [];
  return db.getTiersByBoutique(user!.boutiqueId!, type: type);
});

final clientsProvider = FutureProvider<List<LocalTier>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return [];
  return db.getTiersByBoutique(user!.boutiqueId!, type: 'CLIENT');
});
