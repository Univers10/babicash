import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../boutiques/providers/boutique_provider.dart';
import '../../caisse/services/thermal_print_service.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/sessions_provider.dart';
import '../services/session_rapport_service.dart';

/// Détail d'une session de caisse fermée : rapport + ventes rattachées.
class SessionDetailScreen extends ConsumerStatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  bool _printing = false;

  Future<void> _imprimer(SessionDetail detail) async {
    if (!ThermalPrintService.isConnected()) {
      AppSnackbar.error(
        context,
        'Imprimante non connectée. Configurez-la depuis les Paramètres.',
      );
      return;
    }
    setState(() => _printing = true);
    try {
      final nomBoutique =
          ref.read(boutiqueInfoProvider).value?.nom ?? 'BabiCash';
      final lines = buildRapportLines(
        detail.rapport,
        nomBoutique: nomBoutique,
      );
      await ThermalPrintService.printTextLines(lines);
      if (mounted) {
        AppSnackbar.success(context, 'Rapport envoyé à l\'imprimante.');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Échec de l\'impression. Vérifiez l\'imprimante et réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(sessionDetailProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la session'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Session introuvable'));
          }
          return _SessionDetailBody(
            detail: detail,
            printing: _printing,
            onPrint: () => _imprimer(detail),
          );
        },
      ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({
    required this.detail,
    required this.printing,
    required this.onPrint,
  });

  final SessionDetail detail;
  final bool printing;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final s = detail.session;
    final r = detail.rapport;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final estFermee = s.statut == 'FERME';

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: estFermee
                  ? AppColors.surfaceVariant
                  : AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Column(
              children: [
                Icon(
                  estFermee ? Symbols.lock : Symbols.lock_open,
                  size: 32,
                  color: estFermee
                      ? AppColors.textSecondary
                      : AppColors.primary,
                ),
                const VGap(AppSpacing.sm),
                Text(
                  estFermee ? 'Session fermée' : 'Session ouverte',
                  style: AppTextStyles.headlineMedium,
                ),
                const VGap(AppSpacing.xs),
                Text(
                  '${fmt.format(s.dateOuverture.toLocal())}'
                  '${s.dateFermeture != null ? ' → ${fmt.format(s.dateFermeture!.toLocal())}' : ''}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const VGap(AppSpacing.xs),
                Text(
                  'Caissier : ${s.utilisateurNom}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const VGap(AppSpacing.lg),

          // ── Rapport ──────────────────────────────────────────────────
          const Text('Rapport de session', style: AppTextStyles.headlineSmall),
          const VGap(AppSpacing.md),
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _RapportLigne(
                  label: 'Fond de caisse initial',
                  value: AmountText.format(s.montantInitial),
                  icon: Symbols.account_balance_wallet,
                ),
                const _RapportDivider(),
                _RapportLigne(
                  label: 'Ventes (${r.nbVentes})',
                  value: AmountText.format(r.totalVentes),
                  icon: Symbols.receipt_long,
                ),
                if (r.totalEspeces > 0)
                  _RapportLigne(
                    label: 'dont espèces',
                    value: AmountText.format(r.totalEspeces),
                    icon: Symbols.payments,
                    indent: true,
                  ),
                if (r.totalMobile > 0)
                  _RapportLigne(
                    label: 'dont mobile money',
                    value: AmountText.format(r.totalMobile),
                    icon: Symbols.phone_android,
                    indent: true,
                  ),
                if (r.totalCredit > 0)
                  _RapportLigne(
                    label: 'dont crédit',
                    value: AmountText.format(r.totalCredit),
                    icon: Symbols.credit_card,
                    indent: true,
                  ),
                const _RapportDivider(),
                _RapportLigne(
                  label: 'Dépenses (${detail.depenses.length})',
                  value: '- ${AmountText.format(r.totalDepenses)}',
                  icon: Symbols.arrow_upward,
                  color: r.totalDepenses > 0 ? AppColors.error : null,
                ),
                const _RapportDivider(),
                _RapportLigne(
                  label: 'Théorique caisse',
                  value: AmountText.format(r.montantTheorique),
                  icon: Symbols.calculate,
                ),
                if (s.montantFinalDeclare != null)
                  _RapportLigne(
                    label: 'Fond déclaré',
                    value: AmountText.format(s.montantFinalDeclare!),
                    icon: Symbols.account_balance,
                  ),
                if (r.ecart != null) ...[
                  const VGap(AppSpacing.sm),
                  _EcartBadge(ecart: r.ecart!),
                ],
              ],
            ),
          ),
          const VGap(AppSpacing.lg),

          // ── Impression ───────────────────────────────────────────────
          AppButton(
            label: 'Imprimer le rapport',
            onPressed: onPrint,
            isLoading: printing,
            icon: Symbols.print,
          ),
          const VGap(AppSpacing.xl),

          // ── Ventes rattachées ────────────────────────────────────────
          Text(
            'Ventes de la session (${detail.ventes.length})',
            style: AppTextStyles.headlineSmall,
          ),
          const VGap(AppSpacing.md),
          if (detail.ventes.isEmpty)
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  const Icon(Symbols.point_of_sale,
                      size: 32, color: AppColors.textDisabled),
                  const VGap(AppSpacing.sm),
                  Text(
                    'Aucune vente locale pour cette session',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            )
          else
            ...detail.ventes.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _VenteTile(
                  vente: v,
                  clientNom:
                      v.tierId != null ? detail.clientNoms[v.tierId] : null,
                ),
              ),
            ),
          const VGap(AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Sous-widgets ──────────────────────────────────────────────────────────────

class _RapportLigne extends StatelessWidget {
  const _RapportLigne({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.indent = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: indent ? AppSpacing.xl : 0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c),
          const HGap(AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: indent ? FontWeight.w500 : FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RapportDivider extends StatelessWidget {
  const _RapportDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(color: AppColors.borderLight, height: 1),
    );
  }
}

class _EcartBadge extends StatelessWidget {
  const _EcartBadge({required this.ecart});
  final double ecart;

  @override
  Widget build(BuildContext context) {
    final color = ecart == 0
        ? AppColors.success
        : ecart > 0
            ? AppColors.primary
            : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(ecart == 0 ? Symbols.check : Symbols.warning,
              size: 18, color: color),
          const HGap(AppSpacing.sm),
          Expanded(
            child: Text(
              'Écart de clôture',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${ecart >= 0 ? '+' : ''}${AmountText.format(ecart)}',
            style: AppTextStyles.labelLarge
                .copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _VenteTile extends StatelessWidget {
  const _VenteTile({required this.vente, this.clientNom});
  final LocalVente vente;
  final String? clientNom;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM HH:mm');
    final color = _modeColor(vente.modePaiement);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(_modeIcon(vente.modePaiement), size: 16, color: color),
          ),
          const HGap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientNom ?? _modeLabel(vente.modePaiement),
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fmt.format(vente.dateVente.toLocal()),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            AmountText.format(vente.montantTotal),
            style:
                AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'ESPECES':
        return AppColors.success;
      case 'MOBILE_MONEY':
        return AppColors.accent;
      case 'CREDIT':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'ESPECES':
        return Symbols.payments;
      case 'MOBILE_MONEY':
        return Symbols.phone_android;
      case 'CREDIT':
        return Symbols.credit_card;
      default:
        return Symbols.receipt;
    }
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'ESPECES':
        return 'Espèces';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      case 'CREDIT':
        return 'Crédit';
      default:
        return mode;
    }
  }
}
