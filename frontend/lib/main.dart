import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  VideoPlayerController? _ctrl;
  bool _splashDone = false;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // Copier l'asset dans un fichier temporaire (contourne le bug Android)
      final byteData = await rootBundle.load('assets/images/anime_logo.mp4');
      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File('${tmpDir.path}/anime_logo.mp4');
      await tmpFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      final ctrl = VideoPlayerController.file(tmpFile);
      await ctrl.initialize();

      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _ctrl = ctrl;
      setState(() => _videoReady = true);
      await ctrl.play();
      ctrl.addListener(_onVideoProgress);
    } catch (e) {
      debugPrint('video_player init error: $e');
      if (mounted && !_splashDone) setState(() => _splashDone = true);
    }
  }

  void _onVideoProgress() {
    if (!mounted || _ctrl == null) return;
    final pos = _ctrl!.value.position;
    final dur = _ctrl!.value.duration;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _ctrl!.removeListener(_onVideoProgress);
      if (!_splashDone) setState(() => _splashDone = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onVideoProgress);
    _ctrl?.dispose();
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
          backgroundColor: const Color(0xFFEAEAEA),
          body: Center(
            child: _videoReady && _ctrl != null
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _ctrl!.value.size.width,
                        height: _ctrl!.value.size.height,
                        child: VideoPlayer(_ctrl!),
                      ),
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
