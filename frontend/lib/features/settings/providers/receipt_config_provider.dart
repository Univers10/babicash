import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/receipt_config.dart';
import '../services/receipt_settings_storage.dart';

/// Gère la personnalisation du reçu (infos boutique, en-tête, pied de page,
/// options d'affichage).
///
/// L'état est chargé depuis le secure storage uniquement : aucune dépendance
/// réseau, la config reste lisible hors-ligne au moment de la vente. Le
/// pré-remplissage depuis la boutique active est géré côté écran de
/// paramétrage, pas ici, pour ne pas coupler l'impression à l'API.
class ReceiptConfigNotifier extends AsyncNotifier<ReceiptConfig> {
  ReceiptSettingsStorage get _storage =>
      ref.read(receiptSettingsStorageProvider);

  @override
  Future<ReceiptConfig> build() async {
    return await _storage.load() ?? const ReceiptConfig();
  }

  /// Enregistre la personnalisation [config] et met à jour l'état.
  Future<void> save(ReceiptConfig config) async {
    await _storage.save(config);
    state = AsyncData(config);
  }

  /// Réinitialise la personnalisation aux valeurs par défaut.
  Future<void> reset() async {
    await _storage.clear();
    state = const AsyncData(ReceiptConfig());
  }
}

final receiptConfigProvider =
    AsyncNotifierProvider<ReceiptConfigNotifier, ReceiptConfig>(
  ReceiptConfigNotifier.new,
);
