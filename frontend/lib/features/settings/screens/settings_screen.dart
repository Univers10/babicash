import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/menu_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Profil ───────────────────────────────────────────────────────
          _SectionTitle('Compte'),
          _SettingsCard(
            icon: Symbols.person,
            title: user?.nom ?? 'Utilisateur',
            subtitle: user?.isOwner == true ? 'Propriétaire' : 'Manager',
            color: AppColors.primary,
          ),
          const VGap(AppSpacing.lg),

          // ── Gestion ────────────────────────────────────────────────────────
          _SectionTitle('Gestion'),
          _SettingsTile(
            icon: Symbols.store,
            title: 'Boutiques',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Symbols.card_membership,
            title: 'Abonnement & quota',
            onTap: () {},
          ),
          const VGap(AppSpacing.lg),

          // ── Préférences ───────────────────────────────────────────────────
          _SectionTitle('Préférences'),
          _SettingsTile(
            icon: Symbols.sync,
            title: 'Synchroniser maintenant',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Symbols.dark_mode,
            title: 'Thème',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Symbols.language,
            title: 'Langue',
            onTap: () {},
          ),
          const VGap(AppSpacing.lg),

          // ── Déconnexion ───────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Symbols.logout),
            label: const Text('Déconnexion'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const HGap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
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
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      onTap: onTap,
    );
  }
}
