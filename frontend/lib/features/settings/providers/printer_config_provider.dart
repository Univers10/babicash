import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_universal_printer/pos_universal_printer.dart';

import '../../caisse/services/thermal_print_service.dart';
import '../models/saved_printer.dart';
import '../services/printer_settings_storage.dart';

/// Abstraction du matériel d'impression, mockable en test.
/// L'implémentation par défaut délègue à [ThermalPrintService].
class PrinterConnector {
  const PrinterConnector();

  Stream<PrinterDevice> scan() => ThermalPrintService.scanDevices();

  Future<bool> connect(SavedPrinter printer) =>
      ThermalPrintService.connectSaved(printer);

  Future<void> disconnect() => ThermalPrintService.disconnect();

  bool get isConnected => ThermalPrintService.isConnected();

  Future<void> printTest({required String nomBoutique}) =>
      ThermalPrintService.printTest(nomBoutique: nomBoutique);
}

final printerConnectorProvider = Provider<PrinterConnector>((ref) {
  return const PrinterConnector();
});

/// État de la configuration imprimante.
class PrinterConfigState {
  const PrinterConfigState({this.saved, this.connected = false});

  /// Imprimante mémorisée (`null` si aucune n'est configurée).
  final SavedPrinter? saved;

  /// La connexion Bluetooth est-elle active ?
  final bool connected;

  PrinterConfigState copyWith({SavedPrinter? saved, bool? connected}) =>
      PrinterConfigState(
        saved: saved ?? this.saved,
        connected: connected ?? this.connected,
      );
}

/// Gère la sélection, la mémorisation et la connexion de l'imprimante
/// thermique par défaut.
class PrinterConfigNotifier extends AsyncNotifier<PrinterConfigState> {
  PrinterSettingsStorage get _storage => ref.read(printerSettingsStorageProvider);
  PrinterConnector get _connector => ref.read(printerConnectorProvider);

  @override
  Future<PrinterConfigState> build() async {
    final saved = await _storage.load();
    return PrinterConfigState(
      saved: saved,
      connected: saved != null && _connector.isConnected,
    );
  }

  /// Mémorise l'imprimante ([name] + [address] MAC) puis tente la connexion.
  ///
  /// L'imprimante est persistée même si la connexion échoue (elle sera
  /// retentée automatiquement à la prochaine impression).
  /// Retourne `true` si la connexion est établie.
  Future<bool> selectPrinter({
    required String name,
    required String address,
  }) async {
    final printer = SavedPrinter(name: name, address: address);
    await _storage.save(printer);
    var ok = false;
    try {
      ok = await _connector.connect(printer);
    } catch (_) {
      ok = false;
    }
    state = AsyncData(PrinterConfigState(saved: printer, connected: ok));
    return ok;
  }

  /// Retente la connexion à l'imprimante mémorisée.
  /// Retourne `false` si aucune imprimante n'est mémorisée ou joignable.
  Future<bool> reconnect() async {
    final saved = state.value?.saved ?? await _storage.load();
    if (saved == null) return false;
    var ok = false;
    try {
      ok = await _connector.connect(saved);
    } catch (_) {
      ok = false;
    }
    state = AsyncData(PrinterConfigState(saved: saved, connected: ok));
    return ok;
  }

  /// Oublie l'imprimante mémorisée et coupe la connexion en cours.
  Future<void> forget() async {
    try {
      await _connector.disconnect();
    } catch (_) {
      // Déconnexion best-effort : l'oubli doit aboutir quoi qu'il arrive.
    }
    await _storage.clear();
    state = const AsyncData(PrinterConfigState());
  }

  /// Imprime un ticket de test sur l'imprimante mémorisée.
  ///
  /// Relaye [ImprimanteIndisponibleException] à l'appelant et met à jour
  /// l'état de connexion en conséquence.
  Future<void> printTest({required String nomBoutique}) async {
    try {
      await _connector.printTest(nomBoutique: nomBoutique);
      _setConnected(true);
    } on ImprimanteIndisponibleException {
      _setConnected(false);
      rethrow;
    }
  }

  void _setConnected(bool connected) {
    final current = state.value;
    if (current == null || current.saved == null) return;
    state = AsyncData(current.copyWith(connected: connected));
  }
}

final printerConfigProvider =
    AsyncNotifierProvider<PrinterConfigNotifier, PrinterConfigState>(
  PrinterConfigNotifier.new,
);
