import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:pos_universal_printer/pos_universal_printer.dart';

import '../../settings/models/saved_printer.dart';
import '../../settings/services/printer_settings_storage.dart';
import '../screens/ticket_screen.dart';

/// Levée quand aucune imprimante n'est connectée et que la reconnexion
/// automatique à l'imprimante mémorisée a échoué.
class ImprimanteIndisponibleException implements Exception {
  const ImprimanteIndisponibleException([
    this.message = 'Imprimante injoignable. Vérifiez qu\'elle est allumée '
        'ou configurez-la dans Paramètres.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Service d'impression thermique Bluetooth (ESC/POS, largeur 58 mm).
///
/// L'imprimante par défaut est celle mémorisée depuis l'écran
/// « Configurer l'imprimante » (Paramètres) : avant chaque impression,
/// [ensureConnected] réutilise la connexion active ou se reconnecte
/// automatiquement à l'imprimante mémorisée.
///
/// API publique d'impression ([printTicket], [scanDevices],
/// [connectDevice], [disconnect], [isConnected]) : rétro-compatible,
/// consommée aussi par les rapports de session.
class ThermalPrintService {
  static final _printer = PosUniversalPrinter.instance;
  static const _role = PosPrinterRole.cashier;

  /// Persistance de la configuration imprimante (remplaçable en test).
  static PrinterSettingsStorage settings =
      const PrinterSettingsStorage(FlutterSecureStorage());

  // ── Découverte / connexion (API existante) ─────────────────────────────────

  /// Liste les imprimantes Bluetooth appairées (Android).
  static Stream<PrinterDevice> scanDevices() => _printer.scanBluetooth();

  /// Connecte [device] comme imprimante de caisse (reconnexion auto activée).
  static Future<void> connectDevice(PrinterDevice device) async {
    await _printer.registerDevice(_role, device);
    _printer.setAutoReconnect(_role, true);
  }

  static Future<void> disconnect() async {
    await _printer.unregisterDevice(_role);
  }

  static bool isConnected() => _printer.isRoleConnected(_role);

  // ── Imprimante mémorisée ───────────────────────────────────────────────────

  /// Imprimante mémorisée dans les paramètres, ou `null`.
  static Future<SavedPrinter?> savedPrinter() => settings.load();

  /// Tente la connexion à l'imprimante mémorisée [saved].
  /// Retourne `true` si la connexion est établie.
  static Future<bool> connectSaved(SavedPrinter saved) async {
    await connectDevice(PrinterDevice(
      id: saved.address,
      name: saved.name,
      type: PrinterType.bluetooth,
      address: saved.address,
    ));
    return isConnected();
  }

  /// Garantit une connexion imprimante : réutilise la connexion active,
  /// sinon se reconnecte automatiquement à l'imprimante mémorisée.
  /// Retourne `false` si aucune imprimante n'est mémorisée ou joignable.
  static Future<bool> ensureConnected() async {
    if (isConnected()) return true;
    final saved = await savedPrinter();
    if (saved == null) return false;
    try {
      return await connectSaved(saved);
    } catch (_) {
      return false;
    }
  }

  // ── Impression ─────────────────────────────────────────────────────────────

  /// Imprime le ticket de caisse de [vente].
  ///
  /// Se reconnecte automatiquement à l'imprimante mémorisée si besoin ;
  /// lève [ImprimanteIndisponibleException] si aucune imprimante n'est
  /// joignable.
  static Future<void> printTicket(VenteResume vente) async {
    if (!await ensureConnected()) {
      throw const ImprimanteIndisponibleException();
    }

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    const w = 32; // largeur 58mm

    final b = EscPosBuilder();
    b.init();
    b.text(vente.nomBoutique, align: PosAlign.center, bold: true);
    for (final ligne in vente.enteteLignes) {
      b.text(ligne, align: PosAlign.center);
    }
    if ((vente.adresse ?? '').trim().isNotEmpty) {
      b.text(vente.adresse!.trim(), align: PosAlign.center);
    }
    if ((vente.telephone ?? '').trim().isNotEmpty) {
      b.text('Tel: ${vente.telephone!.trim()}', align: PosAlign.center);
    }
    if (vente.caissierNom != null) {
      b.text('Vendeur: ${vente.caissierNom}', align: PosAlign.center);
    }
    b.feed(1);
    b.text(fmt.format(vente.date), align: PosAlign.center);
    b.text('-' * w);
    b.feed(1);

    for (final item in vente.lignes) {
      final remisePct =
          item.remise > 0 ? ' (-${item.remise.toStringAsFixed(0)}%)' : '';
      b.text('${item.nom}$remisePct', bold: true);
      final right = '${item.total.toStringAsFixed(0)}F';
      final left = '  ${item.quantite}x${item.prixApresRemise.toStringAsFixed(0)}F';
      b.text(_lr(left, right, w));
    }

    b.text('-' * w);
    b.feed(1);

    if (vente.remiseGlobale > 0) {
      final eco = (vente.sousTotal - vente.total).toStringAsFixed(0);
      b.text(_lr('Remise ${vente.remiseGlobale.toStringAsFixed(0)}%', '-$eco F', w));
    }

    b.text('=' * w);
    b.text(_lr('TOTAL', '${vente.total.toStringAsFixed(0)} F', w), bold: true);
    b.text('=' * w);
    b.feed(1);

    if (vente.clientNom != null) {
      b.text(_lr('Client', vente.clientNom!, w), bold: true);
    }
    b.text(_lr('Mode', vente.modePaiement.toUpperCase(), w));

    if (vente.montantRecu > 0 && vente.montantRecu != vente.total) {
      b.text(_lr('Recu', '${vente.montantRecu.toStringAsFixed(0)} F', w));
      if (vente.monnaie > 0) {
        b.text(_lr('Monnaie', '${vente.monnaie.toStringAsFixed(0)} F', w), bold: true);
      }
    }

    if (vente.piedMessage.trim().isNotEmpty) {
      b.feed(1);
      b.text(vente.piedMessage.trim(), align: PosAlign.center);
    }
    b.feed(3);
    b.cut();

    _printer.printEscPos(_role, b);
  }

  /// Imprime un court ticket de test (nom boutique, date, confirmation).
  ///
  /// Lève [ImprimanteIndisponibleException] si aucune imprimante n'est
  /// joignable.
  static Future<void> printTest({required String nomBoutique}) async {
    if (!await ensureConnected()) {
      throw const ImprimanteIndisponibleException();
    }

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    const w = 32;

    final b = EscPosBuilder();
    b.init();
    b.text(nomBoutique, align: PosAlign.center, bold: true);
    b.text(fmt.format(DateTime.now()), align: PosAlign.center);
    b.feed(1);
    b.text('-' * w);
    b.text('Test d\'impression reussi', align: PosAlign.center, bold: true);
    b.text('-' * w);
    b.feed(3);
    b.cut();

    _printer.printEscPos(_role, b);
  }

  /// Imprime un texte libre, une chaîne par ligne (déjà formatée en 32 col).
  /// Utilisé par les rapports de session. Ne fait rien de plus que l'envoi :
  /// l'appelant vérifie [isConnected] avant d'appeler.
  static Future<void> printTextLines(List<String> lines) async {
    final b = EscPosBuilder();
    b.init();
    for (final line in lines) {
      b.text(line);
    }
    b.feed(3);
    b.cut();
    _printer.printEscPos(PosPrinterRole.cashier, b);
  }

  static String _lr(String left, String right, int width) {
    final spaces = width - left.length - right.length;
    return spaces > 0 ? left + ' ' * spaces + right : '$left $right';
  }
}
