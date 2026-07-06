import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/login_pin_screen.dart';
import '../../features/caisse/screens/caisse_screen.dart';
import '../../features/stock/screens/categories_screen.dart';
import '../../features/stock/screens/stock_screen.dart';
import '../../features/tiers/screens/tiers_screen.dart';
import '../../features/sessions/screens/sessions_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../shared/screens/shell_screen.dart';

// Noms des routes
abstract final class AppRoutes {
  static const login = '/login';
  static const loginPin = '/login-pin';
  static const caisse = '/caisse';
  static const stock = '/stock';
  static const categories = '/categories';
  static const tiers = '/tiers';
  static const sessions = '/sessions';
  static const dashboard = '/dashboard';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.caisse,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.hasValue && authState.value != null;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.loginPin;

      if (!isLoggedIn && !isOnAuth) return AppRoutes.login;
      if (isLoggedIn && isOnAuth) {
        final user = authState.value!;
        return user.isOwner ? AppRoutes.dashboard : AppRoutes.caisse;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPin,
        builder: (_, __) => const LoginPinScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (_, __) => const CategoriesScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.caisse,
            builder: (_, __) => const CaisseScreen(),
          ),
          GoRoute(
            path: AppRoutes.stock,
            builder: (_, __) => const StockScreen(),
          ),
          GoRoute(
            path: AppRoutes.tiers,
            builder: (_, __) => const TiersScreen(),
          ),
          GoRoute(
            path: AppRoutes.sessions,
            builder: (_, __) => const SessionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
        ],
      ),
    ],
  );
});
