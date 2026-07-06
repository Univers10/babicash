import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shell_provider.dart';

class MenuButton extends ConsumerWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        ref.read(shellScaffoldKeyProvider).currentState?.openDrawer();
      },
    );
  }
}
