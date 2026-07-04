import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait uniquement (standard pour les applications de caisse)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: BabiCashApp(),
    ),
  );
}

class BabiCashApp extends ConsumerWidget {
  const BabiCashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authStateProvider);

    // Écran de chargement tant que l'état d'authentification n'est pas résolu
    if (authState.isLoading) {
      return Material(
        color: AppTheme.light.scaffoldBackgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp.router(
      title: 'BabiCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        // Déclenche la sync en arrière-plan dès qu'un utilisateur est connecté
        return _SyncInitializer(child: child!);
      },
    );
  }
}

class _SyncInitializer extends ConsumerWidget {
  const _SyncInitializer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user != null) {
      // Force le lancement du provider de sync (ignoré le résultat)
      ref.watch(syncInitProvider);
    }

    // Respect de la taille de texte système, mais avec un plafond
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: child,
    );
  }
}
