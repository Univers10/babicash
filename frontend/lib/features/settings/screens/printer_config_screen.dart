import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_universal_printer/pos_universal_printer.dart'
    hide Align, Size;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../boutiques/providers/boutique_provider.dart';
import '../../caisse/services/thermal_print_service.dart';
import '../providers/printer_config_provider.dart';

/// États d'échec de la recherche d'imprimantes.
enum _ScanIssue {
  permissionDenied,
  permissionPermanentlyDenied,
  bluetoothOff,
  noneFound,
}

/// Écran « Configurer l'imprimante » : recherche des imprimantes Bluetooth
/// appairées, sélection + mémorisation persistante, test d'impression.
class PrinterConfigScreen extends ConsumerStatefulWidget {
  const PrinterConfigScreen({super.key});

  @override
  ConsumerState<PrinterConfigScreen> createState() =>
      _PrinterConfigScreenState();
}

class _PrinterConfigScreenState extends ConsumerState<PrinterConfigScreen> {
  List<PrinterDevice> _devices = [];
  bool _scanning = false;
  bool _testing = false;
  bool _reconnecting = false;
  String? _busyAddress;
  _ScanIssue? _issue;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _devices = [];
      _issue = null;
    });

    // Permissions runtime (Android 12+ : BLUETOOTH_SCAN / BLUETOOTH_CONNECT).
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        if (statuses.values.any((s) => s.isPermanentlyDenied)) {
          _stopScan(_ScanIssue.permissionPermanentlyDenied);
          return;
        }
        if (statuses.values.any((s) => !s.isGranted)) {
          _stopScan(_ScanIssue.permissionDenied);
          return;
        }

        final service = await Permission.bluetooth.serviceStatus;
        if (service == ServiceStatus.disabled) {
          _stopScan(_ScanIssue.bluetoothOff);
          return;
        }
      } catch (_) {
        // Plugin indisponible sur cette plateforme : on tente le scan direct.
      }
    }

    try {
      final found = <PrinterDevice>[];
      await for (final d in ref.read(printerConnectorProvider).scan()) {
        final address = d.address;
        if (address != null && address.isNotEmpty) found.add(d);
      }
      if (!mounted) return;
      setState(() {
        _devices = found;
        _scanning = false;
        _issue = found.isEmpty ? _ScanIssue.noneFound : null;
      });
    } catch (_) {
      _stopScan(_ScanIssue.noneFound);
    }
  }

  void _stopScan(_ScanIssue issue) {
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _issue = issue;
    });
  }

  Future<void> _select(PrinterDevice device) async {
    final address = device.address;
    if (address == null || address.isEmpty) return;
    setState(() => _busyAddress = address);
    final ok = await ref
        .read(printerConfigProvider.notifier)
        .selectPrinter(name: device.name, address: address);
    if (!mounted) return;
    setState(() {
      _busyAddress = null;
      _devices = [];
      _issue = null;
    });
    if (ok) {
      AppSnackbar.success(
          context, 'Imprimante « ${device.name} » connectée et mémorisée.');
    } else {
      AppSnackbar.warning(
          context,
          'Imprimante mémorisée, mais injoignable pour le moment. '
          'Vérifiez qu\'elle est allumée.');
    }
  }

  Future<void> _reconnect() async {
    setState(() => _reconnecting = true);
    final ok = await ref.read(printerConfigProvider.notifier).reconnect();
    if (!mounted) return;
    setState(() => _reconnecting = false);
    if (ok) {
      AppSnackbar.success(context, 'Imprimante connectée.');
    } else {
      AppSnackbar.error(context,
          'Imprimante injoignable. Vérifiez qu\'elle est allumée et à portée.');
    }
  }

  Future<void> _testPrint() async {
    setState(() => _testing = true);
    final nomBoutique =
        ref.read(boutiqueInfoProvider).valueOrNull?.nom ?? 'BabiCash';
    try {
      await ref
          .read(printerConfigProvider.notifier)
          .printTest(nomBoutique: nomBoutique);
      if (mounted) {
        AppSnackbar.success(context, 'Ticket de test envoyé à l\'imprimante.');
      }
    } on ImprimanteIndisponibleException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Échec du test d\'impression.');
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _forget() async {
    await ref.read(printerConfigProvider.notifier).forget();
    if (mounted) AppSnackbar.info(context, 'Imprimante oubliée.');
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(printerConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Configurer l\'imprimante')),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Text(
              'Impossible de charger la configuration de l\'imprimante.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (config) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _SectionTitle('IMPRIMANTE PAR DÉFAUT'),
            if (config.saved == null)
              const _InfoCard(
                icon: Symbols.print,
                message:
                    'Aucune imprimante configurée. Recherchez puis sélectionnez '
                    'votre imprimante Bluetooth ci-dessous.',
              )
            else
              _SavedPrinterCard(
                name: config.saved!.name,
                address: config.saved!.address,
                connected: config.connected,
                testing: _testing,
                reconnecting: _reconnecting,
                onTest: _testing ? null : _testPrint,
                onReconnect: _reconnecting ? null : _reconnect,
                onForget: _forget,
              ),
            const VGap(AppSpacing.xl),
            const _SectionTitle('IMPRIMANTES APPAIRÉES'),
            Text(
              'L\'imprimante doit d\'abord être appairée dans les réglages '
              'Bluetooth du téléphone.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            const VGap(AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _scanning ? null : _scan,
              icon: _scanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Symbols.bluetooth_searching, size: 20),
              label: Text(_scanning
                  ? 'Recherche en cours...'
                  : 'Rechercher les imprimantes'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, AppSpacing.minTapTarget),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm),
              ),
            ),
            if (_issue != null) ...[
              const VGap(AppSpacing.md),
              _IssueBanner(issue: _issue!),
            ],
            if (_devices.isNotEmpty) ...[
              const VGap(AppSpacing.md),
              ..._devices.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _DeviceTile(
                    device: d,
                    busy: _busyAddress == d.address,
                    enabled: _busyAddress == null,
                    onTap: () => _select(d),
                  ),
                ),
              ),
            ],
            const VGap(AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Widgets privés ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SavedPrinterCard extends StatelessWidget {
  const _SavedPrinterCard({
    required this.name,
    required this.address,
    required this.connected,
    required this.testing,
    required this.reconnecting,
    required this.onTest,
    required this.onReconnect,
    required this.onForget,
  });

  final String name;
  final String address;
  final bool connected;
  final bool testing;
  final bool reconnecting;
  final VoidCallback? onTest;
  final VoidCallback? onReconnect;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(Symbols.print,
                    color: AppColors.primary, size: 22),
              ),
              const HGap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.headlineSmall,
                        overflow: TextOverflow.ellipsis),
                    const VGap(2),
                    Text(address,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const HGap(AppSpacing.sm),
              _StatusChip(connected: connected),
            ],
          ),
          const VGap(AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onTest,
                  icon: testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Symbols.receipt_long, size: 18),
                  label: Text(
                      testing ? 'Impression...' : 'Test d\'impression'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize:
                        const Size.fromHeight(AppSpacing.minTapTarget),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusSm),
                  ),
                ),
              ),
              if (!connected) ...[
                const HGap(AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReconnect,
                    icon: reconnecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Symbols.bluetooth_connected, size: 18),
                    label: Text(reconnecting ? 'Connexion...' : 'Reconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize:
                          const Size.fromHeight(AppSpacing.minTapTarget),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusSm),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const VGap(AppSpacing.xs),
          TextButton.icon(
            onPressed: onForget,
            icon: const Icon(Symbols.delete, size: 18),
            label: const Text('Oublier cette imprimante'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: connected
            ? AppColors.successContainer
            : AppColors.warningContainer,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected
                ? Symbols.bluetooth_connected
                : Symbols.bluetooth_disabled,
            size: 14,
            color: color,
          ),
          const HGap(AppSpacing.xs),
          Text(
            connected ? 'Connectée' : 'Non connectée',
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const HGap(AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueBanner extends StatelessWidget {
  const _IssueBanner({required this.issue});
  final _ScanIssue issue;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String message, bool showSettings) = switch (issue) {
      _ScanIssue.bluetoothOff => (
          Symbols.bluetooth_disabled,
          'Bluetooth désactivé. Activez le Bluetooth du téléphone puis '
              'relancez la recherche.',
          false,
        ),
      _ScanIssue.permissionDenied => (
          Symbols.block,
          'Permission Bluetooth refusée. Autorisez l\'accès Bluetooth pour '
              'rechercher les imprimantes.',
          false,
        ),
      _ScanIssue.permissionPermanentlyDenied => (
          Symbols.block,
          'Permission Bluetooth refusée définitivement. Autorisez le '
              'Bluetooth dans les réglages de l\'application.',
          true,
        ),
      _ScanIssue.noneFound => (
          Symbols.print_disabled,
          'Aucune imprimante trouvée. Vérifiez que l\'imprimante est allumée '
              'et appairée dans les réglages Bluetooth du téléphone.',
          false,
        ),
    };

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.warning),
              const HGap(AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          if (showSettings) ...[
            const VGap(AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Symbols.settings, size: 18),
                label: const Text('Ouvrir les réglages'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final PrinterDevice device;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.borderRadiusMd,
      child: ListTile(
        leading:
            const Icon(Symbols.print, color: AppColors.primary, size: 22),
        title: Text(device.name, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          device.address ?? '',
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
        trailing: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
        shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
