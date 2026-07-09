import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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
      return const _SplashScreen();
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

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  late final VideoPlayerController _ctrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.asset('assets/images/anime_logo.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _ctrl.setLooping(true);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _initialized
              ? SizedBox(
                  width: 240,
                  height: 240,
                  child: AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                )
              : Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                ),
        ),
      ),
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
