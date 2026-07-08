import 'package:pos_universal_printer/pos_universal_printer.dart';
import 'package:intl/intl.dart';
import '../screens/ticket_screen.dart';

class ThermalPrintService {
  static final _printer = PosUniversalPrinter.instance;

  static Stream<PrinterDevice> scanDevices() => _printer.scanBluetooth();

  static Future<void> connectDevice(PrinterDevice device) async {
    await _printer.registerDevice(PosPrinterRole.cashier, device);
  }

  static Future<void> disconnect() async {
    await _printer.unregisterDevice(PosPrinterRole.cashier);
  }

  static bool isConnected() => _printer.isRoleConnected(PosPrinterRole.cashier);

  static Future<void> printTicket(VenteResume vente) async {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    const w = 32; // largeur 58mm

    final b = EscPosBuilder();
    b.init();
    b.text(vente.nomBoutique, align: PosAlign.center, bold: true);
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
    b.text(_lr('Sous-total', '${vente.sousTotal.toStringAsFixed(0)} F', w));

    if (vente.remiseGlobale > 0) {
      final eco = (vente.sousTotal - vente.total).toStringAsFixed(0);
      b.text(_lr('Remise ${vente.remiseGlobale.toStringAsFixed(0)}%', '-$eco F', w));
    }

    b.text('=' * w);
    b.text(_lr('TOTAL', '${vente.total.toStringAsFixed(0)} F', w), bold: true);
    b.text('=' * w);
    b.feed(1);
    b.text(_lr('Mode', vente.modePaiement.toUpperCase(), w));

    if (vente.montantRecu > 0 && vente.montantRecu != vente.total) {
      b.text(_lr('Recu', '${vente.montantRecu.toStringAsFixed(0)} F', w));
      if (vente.monnaie > 0) {
        b.text(_lr('Monnaie', '${vente.monnaie.toStringAsFixed(0)} F', w), bold: true);
      }
    }

    b.feed(1);
    b.text('Merci pour votre achat !', align: PosAlign.center);
    b.feed(3);
    b.cut();

    _printer.printEscPos(PosPrinterRole.cashier, b);
  }

  static String _lr(String left, String right, int width) {
    final spaces = width - left.length - right.length;
    return spaces > 0 ? left + ' ' * spaces + right : '$left $right';
  }
}
