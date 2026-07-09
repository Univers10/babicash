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

class BabiCashApp extends ConsumerStatefulWidget {
  const BabiCashApp({super.key});

  @override
  ConsumerState<BabiCashApp> createState() => _BabiCashAppState();
}

class _BabiCashAppState extends ConsumerState<BabiCashApp> {
  late final VideoPlayerController _ctrl;
  bool _splashDone = false;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.asset('assets/images/anime_logo.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _ctrl.play();
        // Attendre la fin de la vidéo pour quitter le splash
        _ctrl.addListener(_onVideoProgress);
      });
  }

  void _onVideoProgress() {
    if (!mounted) return;
    final pos = _ctrl.value.position;
    final dur = _ctrl.value.duration;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _ctrl.removeListener(_onVideoProgress);
      if (!_splashDone) setState(() => _splashDone = true);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onVideoProgress);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authStateProvider);

    // Afficher le splash tant que la vidéo n'est pas terminée OU que l'auth charge
    final showSplash = !_splashDone || authState.isLoading;

    if (showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: _videoReady
                ? AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
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

    return MaterialApp.router(
      title: 'BabiCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
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
