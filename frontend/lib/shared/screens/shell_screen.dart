import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isOwner = user?.isOwner ?? false;
    final location = GoRouterState.of(context).matchedLocation;

    final managerItems = [
      _NavItem(label: 'Caisse', icon: Symbols.point_of_sale, route: AppRoutes.caisse),
      _NavItem(label: 'Stock', icon: Symbols.inventory_2, route: AppRoutes.stock),
      _NavItem(label: 'Clients', icon: Symbols.people, route: AppRoutes.tiers),
      _NavItem(label: 'Sessions', icon: Symbols.receipt_long, route: AppRoutes.sessions),
    ];

    final ownerItems = [
      _NavItem(label: 'Dashboard', icon: Symbols.dashboard, route: AppRoutes.dashboard),
      _NavItem(label: 'Caisse', icon: Symbols.point_of_sale, route: AppRoutes.caisse),
      _NavItem(label: 'Stock', icon: Symbols.inventory_2, route: AppRoutes.stock),
      _NavItem(label: 'Tiers', icon: Symbols.people, route: AppRoutes.tiers),
    ];

    final items = isOwner ? ownerItems : managerItems;
    final currentIndex = items.indexWhere((i) => location.startsWith(i.route));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: items.asMap().entries.map((entry) {
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
