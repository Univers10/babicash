import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/abonnement_model.dart';
import '../../../data/models/boutique_model.dart';
import '../../../data/remote/users_api.dart';
import '../../../data/models/auth_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/abonnements/providers/quota_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/boutiques/screens/boutiques_screen.dart';
import '../../../features/sync/sync_service.dart';
import '../../../features/users/providers/users_provider.dart';
import '../../../features/users/screens/users_screen.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/menu_button.dart';

// ── Providers (réutilise quota_provider.dart pour éviter les doublons) ────────

// ── Screen ─────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _syncing = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      final service = ref.read(syncServiceProvider);
      final count = await service.pushPending();
      await service.pullCatalogue();
      if (mounted) {
        AppSnackbar.success(context, 'Synchronisation terminée ($count éléments envoyés).');
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Erreur lors de la synchronisation.');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final boutiqueAsync = ref.watch(boutiqueInfoProvider);
    final abonnementAsync = ref.watch(monPlanProvider);
    final quotaAsync = ref.watch(quotaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ════════════════════════════════════════════════════════════════════
          // ── 1. PROFIL ──────────────────────────────────────────────────────
          // ════════════════════════════════════════════════════════════════════
          const _SectionTitle('PROFIL'),
          _ProfileCard(user: user),
          const VGap(AppSpacing.sm),
          _SettingsTile(
            icon: Symbols.edit,
            title: 'Modifier mon profil',
            onTap: () => _showEditProfileDialog(context),
          ),
          const VGap(AppSpacing.sm),
          _SettingsTile(
            icon: Symbols.pin,
            title: 'Changer le code PIN',
            onTap: () => _showChangePinDialog(context),
          ),
          const VGap(AppSpacing.xl),

          // ════════════════════════════════════════════════════════════════════
          // ── 2. ÉQUIPE ──────────────────────────────────────────────────────
          // ════════════════════════════════════════════════════════════════════
          if (user?.isOwner == true || user?.isManager == true) ...[
            const _SectionTitle('ÉQUIPE'),
            _SettingsTile(
              icon: Symbols.group,
              title: 'Gérer les utilisateurs',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UsersScreen(),
                ),
              ),
            ),
            const VGap(AppSpacing.xl),
          ],

          // ════════════════════════════════════════════════════════════════════
          // ── 2. BOUTIQUE ────────────────────────────────────────────────────
          // ════════════════════════════════════════════════════════════════════
          const _SectionTitle('BOUTIQUE'),
          boutiqueAsync.when(
            loading: () => const _LoadingTile(),
            error: (_, __) => const _ErrorTile(message: 'Impossible de charger la boutique'),
            data: (boutique) => boutique != null
                ? _BoutiqueCard(boutique: boutique)
                : const _ErrorTile(message: 'Aucune boutique trouvée'),
          ),
          const VGap(AppSpacing.sm),
          _SettingsTile(
            icon: Symbols.storefront,
            title: user?.isOwner == true ? 'Gérer mes boutiques' : 'Modifier ma boutique',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BoutiquesScreen(),
              ),
            ),
          ),
          const VGap(AppSpacing.xl),

          // ════════════════════════════════════════════════════════════════════
          // ── 3. ABONNEMENT ──────────────────────────────────────────────────
          // ════════════════════════════════════════════════════════════════════
          const _SectionTitle('ABONNEMENT'),
          abonnementAsync.when(
            loading: () => const _LoadingTile(),
            error: (_, __) => const _ErrorTile(message: 'Erreur chargement abonnement'),
            data: (abo) => abo != null
                ? _AbonnementCard(abonnement: abo)
                : const _ErrorTile(message: 'Abonnement indisponible'),
          ),
          const VGap(AppSpacing.sm),
          quotaAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (quota) => quota != null ? _QuotaCard(quota: quota) : const SizedBox.shrink(),
          ),
          const VGap(AppSpacing.xl),

          // ════════════════════════════════════════════════════════════════════
          // ── 4. PARAMÈTRES ──────────────────────────────────────────────────
          // ════════════════════════════════════════════════════════════════════
          const _SectionTitle('PARAMÈTRES'),
          _SettingsTile(
            icon: Symbols.sync,
            title: 'Synchroniser maintenant',
            trailing: _syncing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            onTap: _syncing ? () {} : _sync,
          ),
          const VGap(AppSpacing.xl),

          // ── Déconnexion ───────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Symbols.logout),
            label: const Text('Déconnexion'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const VGap(AppSpacing.lg),
        ],
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditProfileDialog(ref: ref),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouveau code PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '4 chiffres',
            prefixIcon: const Icon(Symbols.pin),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final pin = ctrl.text.trim();
              if (pin.length != 4 || int.tryParse(pin) == null) {
                AppSnackbar.error(context, 'Le code PIN doit contenir exactement 4 chiffres.');
                return;
              }
              Navigator.pop(ctx);
              await _changePin(pin);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePin(String pin) async {
    try {
      await ref.read(usersApiProvider).changePin(pin);
      if (mounted) AppSnackbar.success(context, 'Code PIN mis à jour.');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Erreur lors du changement de PIN.');
    }
  }

}

// ── Dialog édition profil ──────────────────────────────────────────────────────

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _telephone;
  bool _loading = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController();
    _telephone = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(usersApiProvider).getMyProfile();
      if (mounted) {
        _nom.text = profile.nom;
        _telephone.text = profile.telephone ?? '';
      }
    } catch (_) {
      // Pré-remplir avec le nom de la session si l'API échoue
      final sessionNom = ref.read(authStateProvider).value?.nom ?? '';
      if (mounted) _nom.text = sessionNom;
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final nom = _nom.text.trim();
      final telephone = _telephone.text.trim();

      await ref.read(usersApiProvider).updateMyProfile(
            nom: nom,
            telephone: telephone.isNotEmpty ? telephone : null,
          );

      // Met à jour le nom dans la session locale
      await ref.read(authStateProvider.notifier).updateNom(nom);
      ref.invalidate(myProfileProvider);

      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.success(context, 'Profil mis à jour.');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Erreur lors de la mise à jour du profil.');
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Symbols.manage_accounts, color: AppColors.primary),
          SizedBox(width: 12),
          Text('Mon profil'),
        ],
      ),
      content: _initializing
          ? const SizedBox(
              width: 280,
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 360,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nom,
                      decoration: InputDecoration(
                        labelText: 'Nom complet *',
                        prefixIcon: const Icon(Symbols.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telephone,
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: const Icon(Symbols.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (!_initializing)
          FilledButton.icon(
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Symbols.check),
            onPressed: _loading ? null : _submit,
            label: const Text('Enregistrer'),
          ),
      ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: 4),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final SessionUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              (user?.nom ?? 'U').substring(0, 1).toUpperCase(),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.nom ?? 'Utilisateur', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (user?.isOwner == true ? AppColors.accent : AppColors.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user?.isOwner == true ? 'Propriétaire' : 'Gérant',
                    style: AppTextStyles.caption.copyWith(
                      color: user?.isOwner == true ? AppColors.accentDark : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutiqueCard extends StatelessWidget {
  const _BoutiqueCard({required this.boutique});
  final BoutiqueModel boutique;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Symbols.store, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(boutique.nom, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                if (boutique.typeCommerce != null && boutique.typeCommerce!.isNotEmpty)
                  Text(boutique.typeCommerce!, style: AppTextStyles.bodySmall),
                if (boutique.adresse != null && boutique.adresse!.isNotEmpty)
                  Text(boutique.adresse!, style: AppTextStyles.caption),
                if (boutique.telephone != null && boutique.telephone!.isNotEmpty)
                  Text(boutique.telephone!, style: AppTextStyles.caption),
                Text(
                  'Créée le ${fmt.format(boutique.dateCreation.toLocal())}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AbonnementCard extends StatelessWidget {
  const _AbonnementCard({required this.abonnement});
  final AbonnementOut abonnement;

  @override
  Widget build(BuildContext context) {
    final isPro = abonnement.plan.toUpperCase() != 'FREE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: isPro ? AppColors.accent.withValues(alpha: 0.4) : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPro ? AppColors.accentContainer : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPro ? Symbols.workspace_premium : Symbols.card_membership,
              color: isPro ? AppColors.accentDark : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Plan ${abonnement.plan}', style: AppTextStyles.headlineSmall),
                    if (isPro) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('PRO', style: AppTextStyles.caption.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 9)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${AmountText.format(abonnement.prixTotalMensuel)} / mois',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  const _QuotaCard({required this.quota});
  final QuotaInfo quota;

  @override
  Widget build(BuildContext context) {
    final pct = quota.illimite
        ? 1.0
        : (quota.quotaParBoutique > 0 ? quota.ventesCeMois / quota.quotaParBoutique : 0.0).clamp(0.0, 1.0);
    final remaining = quota.ventesRestantes;
    final color = pct > 0.9 ? AppColors.error : pct > 0.7 ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Symbols.speed, size: 18, color: color),
              const SizedBox(width: 8),
              const Text('Quota ventes ce mois', style: AppTextStyles.labelMedium),
              const Spacer(),
              Text(
                quota.illimite
                    ? '∞'
                    : '${quota.ventesCeMois} / ${quota.quotaParBoutique}',
                style: AppTextStyles.labelLarge.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (remaining != null && !quota.illimite) ...[
            const SizedBox(height: 6),
            Text(
              '$remaining ventes restantes',
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.borderRadiusMd,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        onTap: onTap,
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Row(
        children: [
          const Icon(Symbols.error, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
