import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/abonnement_model.dart';
import '../../../data/models/boutique_model.dart';
import '../../../data/remote/abonnements_api.dart';
import '../../../data/remote/boutiques_api.dart';
import '../../../data/models/auth_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../features/sync/sync_service.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/menu_button.dart';

// ── Providers ──────────────────────────────────────────────────────────────────

final boutiqueInfoProvider = FutureProvider<BoutiqueModel?>((ref) async {
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return null;
  final api = ref.watch(boutiquesApiProvider);
  final list = await api.listBoutiques();
  return list.where((b) => b.id == boutiqueId).firstOrNull;
});

final abonnementInfoProvider = FutureProvider<AbonnementOut?>((ref) async {
  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.monPlan();
  } catch (_) {
    return null;
  }
});

final quotaInfoProvider = FutureProvider<QuotaInfo?>((ref) async {
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return null;
  try {
    final api = ref.watch(abonnementsApiProvider);
    return await api.quotaBoutique(boutiqueId);
  } catch (_) {
    return null;
  }
});

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
    final abonnementAsync = ref.watch(abonnementInfoProvider);
    final quotaAsync = ref.watch(quotaInfoProvider);

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
            icon: Symbols.pin,
            title: 'Changer le code PIN',
            onTap: () => _showChangePinDialog(context),
          ),
          const VGap(AppSpacing.xl),

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
          if (user?.isOwner == true) ...[
            const VGap(AppSpacing.sm),
            _SettingsTile(
              icon: Symbols.edit,
              title: 'Renommer la boutique',
              onTap: () => _showRenameBoutiqueDialog(context, boutiqueAsync.valueOrNull),
            ),
          ],
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
      final dio = ref.read(dioProvider);
      await dio.put('/users/me/pin', data: {'code_pin': pin});
      if (mounted) AppSnackbar.success(context, 'Code PIN mis à jour.');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Erreur lors du changement de PIN.');
    }
  }

  void _showRenameBoutiqueDialog(BuildContext context, BoutiqueModel? boutique) {
    if (boutique == null) return;
    final ctrl = TextEditingController(text: boutique.nom);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Renommer la boutique'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Nom de la boutique',
            prefixIcon: const Icon(Symbols.store),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final nom = ctrl.text.trim();
              if (nom.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final api = ref.read(boutiquesApiProvider);
                await api.renameBoutique(boutique.id, nom);
                ref.invalidate(boutiqueInfoProvider);
                if (mounted) AppSnackbar.success(context, 'Boutique renommée.');
              } catch (_) {
                if (mounted) AppSnackbar.error(context, 'Erreur lors du renommage.');
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
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
    final isPro = abonnement.plan.toUpperCase() != 'GRATUIT';
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
              Text('Quota ventes ce mois', style: AppTextStyles.labelMedium),
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
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
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
      decoration: BoxDecoration(
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
