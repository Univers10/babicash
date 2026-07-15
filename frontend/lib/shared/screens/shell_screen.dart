import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/shell_provider.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(shellScaffoldKeyProvider);
    final user = ref.watch(authStateProvider).value;
    final isOwner = user?.isOwner ?? false;
    final location = GoRouterState.of(context).matchedLocation;

    final menuGroups = [
      const _MenuGroup(
        label: 'Opérations',
        items: [
          _NavItem(label: 'Caisse', icon: Symbols.point_of_sale, route: AppRoutes.caisse),
          _NavItem(label: 'Stock', icon: Symbols.inventory_2, route: AppRoutes.stock),
          _NavItem(label: 'Catégories', icon: Symbols.category, route: AppRoutes.categories),
        ],
      ),
      const _MenuGroup(
        label: 'Gestion',
        items: [
          _NavItem(label: 'Tiers', icon: Symbols.people, route: AppRoutes.tiers),
          _NavItem(label: 'Historique', icon: Symbols.history, route: AppRoutes.historique),
          _NavItem(label: 'Sessions', icon: Symbols.receipt_long, route: AppRoutes.sessions),
        ],
      ),
      _MenuGroup(
        label: 'Paramètres',
        items: [
          const _NavItem(label: 'Profil', icon: Symbols.person, route: AppRoutes.settings),
          const _NavItem(label: 'Boutiques', icon: Symbols.store, route: AppRoutes.settings),
          if (isOwner)
            const _NavItem(label: 'Abonnement', icon: Symbols.card_membership, route: AppRoutes.abonnement),
          const _NavItem(label: 'Paramètres', icon: Symbols.settings, route: AppRoutes.settings),
        ],
      ),
      if (isOwner)
        const _MenuGroup(
          label: 'Propriétaire',
          items: [
            _NavItem(label: 'Dashboard', icon: Symbols.dashboard, route: AppRoutes.dashboard),
          ],
        ),
    ];

    final bottomItems = isOwner
        ? [
            const _NavItem(label: 'Dashboard', icon: Symbols.dashboard, route: AppRoutes.dashboard),
            const _NavItem(label: 'Caisse', icon: Symbols.point_of_sale, route: AppRoutes.caisse),
            const _NavItem(label: 'Historique', icon: Symbols.history, route: AppRoutes.historique),
            const _NavItem(label: 'Stock', icon: Symbols.inventory_2, route: AppRoutes.stock),
          ]
        : [
            const _NavItem(label: 'Caisse', icon: Symbols.point_of_sale, route: AppRoutes.caisse),
            const _NavItem(label: 'Stock', icon: Symbols.inventory_2, route: AppRoutes.stock),
            const _NavItem(label: 'Historique', icon: Symbols.history, route: AppRoutes.historique),
            const _NavItem(label: 'Sessions', icon: Symbols.receipt_long, route: AppRoutes.sessions),
          ];
    final currentIndex = bottomItems.indexWhere((i) => location.startsWith(i.route));

    return Scaffold(
      key: key,
      body: child,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.onPrimary,
                      child: Icon(Symbols.store, color: AppColors.primary),
                    ),
                    const VGap(AppSpacing.md),
                    Text(
                      'BabiCash',
                      style: AppTextStyles.headlineSmall.copyWith(color: AppColors.onPrimary),
                    ),
                    if (user != null)
                      Text(
                        user.nom,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8)),
                      ),
                    if (user != null)
                      Text(
                        user.isOwner ? 'Propriétaire' : 'Manager',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: menuGroups.length,
                  itemBuilder: (context, index) {
                    final group = menuGroups[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.xs,
                          ),
                          child: Text(
                            group.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...group.items.map((item) {
                          final isSelected = location.startsWith(item.route);
                          return ListTile(
                            leading: Icon(
                              item.icon,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            title: Text(
                              item.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            selected: isSelected,
                            selectedTileColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusLg,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go(item.route);
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Symbols.logout, color: AppColors.error),
                title: Text('Déconnexion', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authStateProvider.notifier).logout();
                },
              ),
              const VGap(AppSpacing.sm),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: bottomItems.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.route),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            fill: isSelected ? 1.0 : 0.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
  final String label;
  final IconData icon;
  final String route;
}

class _MenuGroup {
  const _MenuGroup({required this.label, required this.items});
  final String label;
  final List<_NavItem> items;
}
