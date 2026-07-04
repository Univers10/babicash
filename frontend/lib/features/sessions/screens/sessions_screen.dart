import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

final _sessionProvider = FutureProvider<LocalSession?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return null;
  return db.getSessionOuverte(user!.boutiqueId!);
});

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(_sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Session de caisse')),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (session) => session == null
            ? _OuvertureSession()
            : _SessionActive(session: session),
      ),
    );
  }
}

// ── Ouverture session ─────────────────────────────────────────────────────────

class _OuvertureSession extends ConsumerStatefulWidget {
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
    final user = ref.read(authStateProvider).value;
    if (user?.boutiqueId == null) return;

    setState(() => _loading = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.upsertSession(LocalSessionsCompanion(
        id: drift.Value(const Uuid().v4()),
        boutiqueId: drift.Value(user!.boutiqueId!),
        utilisateurNom: drift.Value(user.nom),
        montantInitial: drift.Value(montant),
        statut: const drift.Value('OUVERT'),
        synced: const drift.Value(false),
      ));
      ref.invalidate(_sessionProvider);
    } finally {
      setState(() => _loading = false);
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
      final db = ref.read(appDatabaseProvider);
      await db.upsertSession(LocalSessionsCompanion(
        id: drift.Value(widget.session.id),
        boutiqueId: drift.Value(widget.session.boutiqueId),
        utilisateurNom: drift.Value(widget.session.utilisateurNom),
        montantInitial: drift.Value(widget.session.montantInitial),
        montantFinalDeclare: drift.Value(montant),
        dateFermeture: drift.Value(DateTime.now()),
        statut: const drift.Value('FERME'),
        synced: const drift.Value(false),
      ));
      ref.invalidate(_sessionProvider);
      if (mounted) AppSnackbar.success(context, 'Session fermée.');
    } finally {
      setState(() => _loading = false);
    }
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
