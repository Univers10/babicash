import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';
import '../screens/lock_screen.dart';

/// Observe le cycle de vie de l'app et superpose l'écran de verrouillage
/// au-dessus du navigateur quand [appLockProvider] passe à `true`.
///
/// L'overlay (Stack) préserve intégralement l'état de navigation et le
/// panier : une fois le PIN validé, l'utilisateur retrouve exactement
/// l'écran où il était.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
        // Arrière-plan effectif. `inactive` est volontairement ignoré
        // (dialogs système, multi-fenêtre) pour éviter les faux positifs.
        lock.onAppPaused();
      case AppLifecycleState.resumed:
        lock.onAppResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    return Stack(
      children: [
        widget.child,
        if (locked) const LockScreen(),
      ],
    );
  }
}
