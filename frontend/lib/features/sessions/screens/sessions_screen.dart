import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../data/models/session_model.dart';
import '../providers/sessions_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/menu_button.dart';

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
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: const Icon(Symbols.lock_open,
                size: 40, color: AppColors.primary),
          ),
          const VGap(AppSpacing.xl),
          Text('Ouvrir la session', style: AppTextStyles.headlineLarge),
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
            decoration: BoxDecoration(
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
          const VGap(AppSpacing.xxxl),

          // Fermeture
          Text('Fermer la session', style: AppTextStyles.headlineSmall),
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
            Text('Session fermée', style: AppTextStyles.headlineMedium),
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
