import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/sync/sync_service.dart';
import '../models/receipt_config.dart';
import '../services/recu_config_repository.dart';

/// Gère la personnalisation du reçu (infos boutique, en-tête, pied de page,
/// options d'affichage) pour la boutique active.
///
/// La config est persistée dans Drift (offline-first) et synchronisée avec le
/// backend via le [SyncService] — voir [RecuConfigRepository]. Elle survit donc
/// à la réinstallation et se retrouve sur les autres appareils du commerçant.
class ReceiptConfigNotifier extends AsyncNotifier<ReceiptConfig> {
  RecuConfigRepository get _repo => ref.read(recuConfigRepositoryProvider);

  @override
  Future<ReceiptConfig> build() async {
    final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) return const ReceiptConfig();
    return _repo.load(boutiqueId);
  }

  /// Enregistre la personnalisation [config] localement, met à jour l'état et
  /// tente un envoi immédiat (silencieux hors-ligne : retenté plus tard).
  Future<void> save(ReceiptConfig config) async {
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId == null) return;
    await _repo.save(boutiqueId, config);
    state = AsyncData(config);
    unawaited(ref.read(syncServiceProvider).pushPending());
  }

  /// Réinitialise la personnalisation aux valeurs par défaut (propagée au
  /// serveur au prochain sync).
  Future<void> reset() async {
    const config = ReceiptConfig();
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (boutiqueId != null) {
      await _repo.save(boutiqueId, config);
      unawaited(ref.read(syncServiceProvider).pushPending());
    }
    state = const AsyncData(config);
  }
}

final receiptConfigProvider =
    AsyncNotifierProvider<ReceiptConfigNotifier, ReceiptConfig>(
  ReceiptConfigNotifier.new,
);
