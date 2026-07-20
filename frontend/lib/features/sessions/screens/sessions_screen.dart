import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/vente_model.dart';
import '../../../data/remote/ventes_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../providers/sessions_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/menu_button.dart';

/// Ventes de la session active (depuis le backend).
final sessionVentesProvider = FutureProvider.family<VenteListResponse, String>((ref, sessionId) async {
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return const VenteListResponse(total: 0, ventes: []);
  final api = ref.watch(ventesApiProvider);
  return api.listVentes(boutiqueId: boutiqueId, sessionId: sessionId, limit: 200);
});

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Session de caisse'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.history),
            tooltip: 'Historique des sessions',
            onPressed: () => context.push(AppRoutes.sessionsHistorique),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
        data: (session) => session == null
            ? const _OuvertureSession()
            : _SessionActive(session: session),
      ),
    );
  }
}

// ── Ouverture session ─────────────────────────────────────────────────────────

class _OuvertureSession extends ConsumerStatefulWidget {
  const _OuvertureSession();

  @override
  ConsumerState<_OuvertureSession> createState() => _OuvertureSessionState();
}

class _OuvertureSessionState extends ConsumerState<_OuvertureSession> {
  final _fondCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fondCtrl.dispose();
    super.dispose();
  }

  Future<void> _ouvrir() async {
    final montant = double.tryParse(_fondCtrl.text) ?? 0;
    setState(() => _loading = true);
    try {
      final ok = await ref
          .read(sessionNotifierProvider.notifier)
          .ouvrir(montant);
      if (!ok && mounted) {
        AppSnackbar.error(context, 'Impossible d\'ouvrir la session.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: const Icon(Symbols.lock_open,
                size: 40, color: AppColors.primary),
          ),
          const VGap(AppSpacing.xl),
          const Text('Ouvrir la session', style: AppTextStyles.headlineLarge),
          const VGap(AppSpacing.sm),
          Text(
            'Déclarez votre fond de caisse initial.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const VGap(AppSpacing.xxxl),
          AppTextField(
            controller: _fondCtrl,
            label: 'Fond de caisse (FCFA)',
            hint: '0',
            keyboardType: TextInputType.number,
            prefixIcon: Symbols.payments,
          ),
          const VGap(AppSpacing.xxl),
          AppButton(
            label: 'Ouvrir la session',
            onPressed: _ouvrir,
            isLoading: _loading,
            icon: Symbols.play_circle,
          ),
        ],
      ),
    );
  }
}

// ── Session active ────────────────────────────────────────────────────────────

class _SessionActive extends ConsumerStatefulWidget {
  const _SessionActive({required this.session});
  final LocalSession session;

  @override
  ConsumerState<_SessionActive> createState() => _SessionActiveState();
}

class _SessionActiveState extends ConsumerState<_SessionActive> {
  final _fondFinalCtrl = TextEditingController();
  bool _loading = false;
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _fondFinalCtrl.dispose();
    super.dispose();
  }

  Future<void> _fermer() async {
    final montant = double.tryParse(_fondFinalCtrl.text);
    if (montant == null) {
      AppSnackbar.error(context, 'Saisissez le fond de caisse final.');
      return;
    }
    setState(() => _loading = true);
    try {
      final resume = await ref
          .read(sessionNotifierProvider.notifier)
          .fermer(montant);
      if (resume != null && mounted) {
        _showRapport(context, resume);
      } else if (mounted) {
        AppSnackbar.error(context, 'Impossible de fermer la session.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRapport(BuildContext context, SessionResumeModel resume) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RapportDialog(resume: resume),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // En-tête session
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Column(
              children: [
                const Icon(Symbols.lock_open,
                    size: 32, color: AppColors.primary),
                const VGap(AppSpacing.sm),
                Text('Session ouverte',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary)),
                const VGap(AppSpacing.xs),
                Text(
                  _fmt.format(widget.session.dateOuverture.toLocal()),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const VGap(AppSpacing.lg),

          // Info fond initial
          _InfoRow(
            label: 'Gérant',
            value: widget.session.utilisateurNom,
            icon: Symbols.person,
          ),
          const VGap(AppSpacing.sm),
          _InfoRow(
            label: 'Fond initial',
            value: AmountText.format(widget.session.montantInitial),
            icon: Symbols.payments,
          ),
          const VGap(AppSpacing.xl),

          // ── Ventes de la session ──────────────────────────────────────
          _SessionVentesList(sessionId: widget.session.id),
          const VGap(AppSpacing.xl),

          // Fermeture
          const Text('Fermer la session', style: AppTextStyles.headlineSmall),
          const VGap(AppSpacing.md),
          AppTextField(
            controller: _fondFinalCtrl,
            label: 'Fond de caisse final (FCFA)',
            hint: '0',
            keyboardType: TextInputType.number,
            prefixIcon: Symbols.payments,
          ),
          const VGap(AppSpacing.xl),
          AppButton(
            label: 'Fermer la session',
            onPressed: _fermer,
            isLoading: _loading,
            icon: Symbols.lock,
            variant: AppButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}

// ── Liste des ventes de la session ─────────────────────────────────────────

class _SessionVentesList extends ConsumerWidget {
  const _SessionVentesList({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventesAsync = ref.watch(sessionVentesProvider(sessionId));
    final fmt = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Symbols.receipt_long, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Ventes de la session', style: AppTextStyles.headlineSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Symbols.refresh, size: 20),
              onPressed: () => ref.invalidate(sessionVentesProvider(sessionId)),
              tooltip: 'Actualiser',
            ),
          ],
        ),
        const VGap(AppSpacing.sm),
        ventesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Text('Erreur de chargement', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
          data: (response) {
            final ventes = response.ventes;
            if (ventes.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Symbols.point_of_sale, size: 32, color: AppColors.textDisabled),
                    const SizedBox(height: 8),
                    Text('Aucune vente pour cette session',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              );
            }

            final totalEspeces = ventes
                .where((v) => v.modePaiement == 'ESPECES')
                .fold(0.0, (s, v) => s + v.montantTotal);
            final totalMobile = ventes
                .where((v) => v.modePaiement == 'MOBILE_MONEY')
                .fold(0.0, (s, v) => s + v.montantTotal);
            final totalCredit = ventes
                .where((v) => v.modePaiement == 'CREDIT')
                .fold(0.0, (s, v) => s + v.montantTotal);
            final totalGlobal = ventes.fold(0.0, (s, v) => s + v.montantTotal);

            return Column(
              children: [
                // Résumé rapide
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _VenteStat(label: 'Total', value: AmountText.format(totalGlobal), color: AppColors.primary),
                      _VenteStat(label: '${ventes.length} ventes', value: '', color: AppColors.textSecondary),
                      if (totalEspeces > 0)
                        _VenteStat(label: 'Espèces', value: AmountText.format(totalEspeces), color: AppColors.success),
                      if (totalMobile > 0)
                        _VenteStat(label: 'Mobile', value: AmountText.format(totalMobile), color: AppColors.accent),
                      if (totalCredit > 0)
                        _VenteStat(label: 'Crédit', value: AmountText.format(totalCredit), color: AppColors.error),
                    ],
                  ),
                ),
                const VGap(AppSpacing.sm),
                // Liste des ventes
                ...ventes.take(50).map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                color: _modeColor(v.modePaiement).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_modeIcon(v.modePaiement), size: 16, color: _modeColor(v.modePaiement)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.clientNom ?? _modeLabel(v.modePaiement),
                                    style: AppTextStyles.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${fmt.format(v.dateVente.toLocal())} · ${v.lignes.length} article${v.lignes.length > 1 ? 's' : ''}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AmountText.format(v.montantTotal),
                              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          },
        ),
      ],
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

class _VenteStat extends StatelessWidget {
  const _VenteStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        if (value.isNotEmpty)
          Text(value, style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const HGap(AppSpacing.md),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary))),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

// ── Rapport de fermeture ─────────────────────────────────────────────────

class _RapportDialog extends StatelessWidget {
  const _RapportDialog({required this.resume});
  final SessionResumeModel resume;

  @override
  Widget build(BuildContext context) {
    final s = resume.session;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final ecart = resume.ecart ?? 0;
    final ecartColor = ecart == 0
        ? AppColors.success
        : ecart > 0
            ? AppColors.primary
            : AppColors.error;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Symbols.check_circle, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 12),
            const Text('Session fermée', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${fmt.format(s.dateOuverture.toLocal())} → ${s.dateFermeture != null ? fmt.format(s.dateFermeture!.toLocal()) : 'Maintenant'}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Stats
            _RapportRow(label: 'Nombre de ventes', value: '${resume.nbVentes}', icon: Symbols.receipt_long),
            const SizedBox(height: 8),
            _RapportRow(label: 'Ventes espèces', value: AmountText.format(resume.totalVentesEspeces), icon: Symbols.payments),
            const SizedBox(height: 8),
            _RapportRow(label: 'Ventes autres', value: AmountText.format(resume.totalVentesAutres), icon: Symbols.credit_card),
            const SizedBox(height: 8),
            _RapportRow(label: 'Entrées', value: AmountText.format(resume.totalEntrees), icon: Symbols.arrow_downward, color: AppColors.success),
            const SizedBox(height: 8),
            _RapportRow(label: 'Sorties', value: AmountText.format(resume.totalSorties), icon: Symbols.arrow_upward, color: AppColors.error),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            // Fond initial / final / théorique / écart
            _RapportRow(label: 'Fond initial', value: AmountText.format(s.montantInitial), icon: Symbols.account_balance_wallet),
            const SizedBox(height: 8),
            _RapportRow(label: 'Fond déclaré', value: AmountText.format(s.montantFinalDeclare ?? 0), icon: Symbols.account_balance),
            const SizedBox(height: 8),
            _RapportRow(label: 'Théorique caisse', value: AmountText.format(resume.montantTheorique), icon: Symbols.calculate),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ecartColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ecartColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(ecart == 0 ? Symbols.check : Symbols.warning, size: 18, color: ecartColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Écart',
                      style: AppTextStyles.bodyMedium.copyWith(color: ecartColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${ecart >= 0 ? '+' : ''}${AmountText.format(ecart)}',
                    style: AppTextStyles.labelLarge.copyWith(color: ecartColor, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bouton fermer
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Symbols.close),
                label: const Text('Fermer le rapport'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RapportRow extends StatelessWidget {
  const _RapportRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ),
        Text(value, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
