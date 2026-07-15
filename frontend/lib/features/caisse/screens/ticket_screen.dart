import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:pos_universal_printer/pos_universal_printer.dart' hide Size;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/panier_item.dart';
import '../services/thermal_print_service.dart';

// ── Modèle résumé de vente ────────────────────────────────────────────────────

class VenteResume {
  const VenteResume({
    required this.lignes,
    required this.sousTotal,
    required this.remiseGlobale,
    required this.total,
    required this.modePaiement,
    required this.montantRecu,
    required this.monnaie,
    required this.date,
    this.nomBoutique = 'BabiCash',
    this.clientNom,
    this.caissierNom,
  });

  final List<PanierItem> lignes;
  final double sousTotal;
  final double remiseGlobale;
  final double total;
  final String modePaiement;
  final double montantRecu;
  final double monnaie;
  final DateTime date;
  final String nomBoutique;
  final String? clientNom;
  final String? caissierNom;
}

// ── Dialog ticket ─────────────────────────────────────────────────────────────

class TicketDialog extends StatefulWidget {
  const TicketDialog({super.key, required this.vente});
  final VenteResume vente;

  @override
  State<TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  List<PrinterDevice> _devices = [];
  PrinterDevice? _selected;
  bool _scanning = false;
  bool _connecting = false;
  bool _printing = false;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _connected = ThermalPrintService.isConnected();
  }

  Future<void> _scan() async {
    // Demander permissions BT runtime (Android 12+)
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final denied = statuses.values.any(
        (s) => s == PermissionStatus.denied || s == PermissionStatus.permanentlyDenied);
    if (denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission Bluetooth refusée. Activez-la dans les paramètres.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _scanning = true;
      _devices = [];
    });
    try {
      final devices = <PrinterDevice>[];
      await for (final d in ThermalPrintService.scanDevices()) {
        devices.add(d);
      }
      if (mounted) setState(() => _devices = devices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du scan'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _connect(PrinterDevice device) async {
    setState(() => _connecting = true);
    await ThermalPrintService.connectDevice(device);
    if (mounted) {
      setState(() {
        _selected = device;
        _connected = ThermalPrintService.isConnected();
        _connecting = false;
      });
    }
  }

  Future<void> _imprimerBT() async {
    setState(() => _printing = true);
    try {
      await ThermalPrintService.printTicket(widget.vente);
    } catch (_) {}
    if (mounted) setState(() => _printing = false);
  }

  VenteResume get vente => widget.vente;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.receipt_long, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Ticket de caisse',
                      style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Corps du ticket
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // En-tête boutique
                    _TicketHeader(nom: vente.nomBoutique, date: fmt.format(vente.date), caissierNom: vente.caissierNom),
                    const _Divider(),

                    // Lignes articles
                    ...vente.lignes.map((item) => _TicketLigne(item: item)),
                    const _Divider(),

                    // Remise globale
                    if (vente.remiseGlobale > 0) ...[
                      _TicketRow(
                        label: 'Remise générale (${vente.remiseGlobale.toStringAsFixed(0)}%)',
                        value: '- ${(vente.sousTotal - vente.total).toStringAsFixed(0)} F',
                        valueColor: AppColors.success,
                      ),
                    ],
                    const _Divider(),

                    // Total
                    _TicketRow(
                      label: 'TOTAL',
                      value: '${vente.total.toStringAsFixed(0)} F',
                      bold: true,
                      valueColor: AppColors.primary,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 8),

                    // Client
                    if (vente.clientNom != null)
                      _TicketRow(
                        label: 'Client',
                        value: vente.clientNom!,
                        bold: true,
                        valueColor: AppColors.primary,
                      ),

                    // Paiement
                    _TicketRow(
                      label: 'Mode de paiement',
                      value: vente.modePaiement.toUpperCase(),
                    ),
                    if (vente.montantRecu > 0 && vente.montantRecu != vente.total) ...[
                      _TicketRow(label: 'Reçu', value: '${vente.montantRecu.toStringAsFixed(0)} F'),
                      if (vente.monnaie > 0)
                        _TicketRow(
                          label: 'Monnaie rendue',
                          value: '${vente.monnaie.toStringAsFixed(0)} F',
                          valueColor: AppColors.success,
                          bold: true,
                        ),
                    ],
                    const _Divider(),

                    // Pied de ticket
                    const SizedBox(height: 4),
                    Text('Merci pour votre achat !',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),

            // Panneau impression
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélecteur imprimante BT
                  Row(
                    children: [
                      Expanded(
                        child: _connected && _selected != null
                            ? Row(
                                children: [
                                  const Icon(Symbols.bluetooth_connected,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(_selected!.name,
                                        style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              )
                            : Text(
                                _devices.isEmpty
                                    ? 'Aucune imprimante'
                                    : '${_devices.length} imprimante(s) trouvée(s)',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                      ),
                      TextButton.icon(
                        onPressed: _scanning ? null : _scan,
                        icon: _scanning
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Symbols.bluetooth_searching, size: 16),
                        label: Text(_scanning ? 'Scan...' : 'Scanner'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  // Liste imprimantes trouvées
                  if (_devices.isNotEmpty && !_connected)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _devices.length,
                        itemBuilder: (_, i) {
                          final d = _devices[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Symbols.print,
                                size: 16, color: AppColors.textSecondary),
                            title: Text(d.name,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textPrimary)),
                            subtitle: Text(d.address ?? '',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textTertiary)),
                            trailing: _connecting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Symbols.chevron_right, size: 16),
                            onTap: _connecting ? null : () => _connect(d),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Boutons actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Symbols.close, size: 16),
                          label: const Text('Fermer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_connected)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _printing ? null : _imprimerBT,
                            icon: _printing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Symbols.print, size: 16),
                            label:
                                Text(_printing ? 'Impression...' : 'Imprimer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _imprimerPdf(context),
                            icon: const Icon(Symbols.picture_as_pdf, size: 16),
                            label: const Text('PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textSecondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _imprimerPdf(BuildContext context) async {
    final doc = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Center(child: pw.Image(logoImage, width: 60, height: 60)),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(vente.nomBoutique,
                    style: const pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ),
              if (vente.caissierNom != null)
                pw.Center(
                  child: pw.Text('Vendeur : ${vente.caissierNom}',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 9)),
                ),
              pw.Center(
                child: pw.Text(fmt.format(vente.date),
                    style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(),

              // Lignes
              ...vente.lignes.map((item) {
                final remisePct = item.remise > 0
                    ? ' (-${item.remise.toStringAsFixed(0)}%)'
                    : '';
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${item.nom}$remisePct',
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            '  ${item.quantite} x ${item.prixApresRemise.toStringAsFixed(0)} F',
                            style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('${item.total.toStringAsFixed(0)} F',
                            style: const pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                  ],
                );
              }),

              pw.Divider(),

              // Remise globale
              if (vente.remiseGlobale > 0)
                _pdfRow(
                  'Remise ${vente.remiseGlobale.toStringAsFixed(0)}%',
                  '- ${(vente.sousTotal - vente.total).toStringAsFixed(0)} F',
                ),

              pw.Divider(),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text('${vente.total.toStringAsFixed(0)} F',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 4),

              if (vente.clientNom != null)
                _pdfRow('Client', vente.clientNom!),
              _pdfRow('Mode', vente.modePaiement.toUpperCase()),
              if (vente.montantRecu > 0 && vente.montantRecu != vente.total) ...[
                _pdfRow('Reçu', '${vente.montantRecu.toStringAsFixed(0)} F'),
                if (vente.monnaie > 0)
                  _pdfRow('Monnaie', '${vente.monnaie.toStringAsFixed(0)} F'),
              ],

              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('Merci pour votre achat !',
                    style: const pw.TextStyle(
                        fontSize: 8, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: 'ticket_${DateFormat('yyyyMMdd_HHmm').format(vente.date)}',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}

// ── Sous-widgets ticket ───────────────────────────────────────────────────────

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.nom, required this.date, this.caissierNom});
  final String nom;
  final String date;
  final String? caissierNom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', width: 72, height: 72),
        const SizedBox(height: 4),
        Text(nom,
            style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        if (caissierNom != null) ...
          [
            const SizedBox(height: 2),
            Text('Vendeur : $caissierNom',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ],
        const SizedBox(height: 2),
        Text(date,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _TicketLigne extends StatelessWidget {
  const _TicketLigne({required this.item});
  final PanierItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nom,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.total.toStringAsFixed(0)} F',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '  ${item.quantite} × ${item.prixApresRemise.toStringAsFixed(0)} F',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
              if (item.remise > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.accentContainer,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '-${item.remise.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentDark),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
    this.fontSize = 13,
  });
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: AppColors.borderLight, height: 1),
    );
  }
}
