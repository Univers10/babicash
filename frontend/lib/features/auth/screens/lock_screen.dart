import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/app_lock_provider.dart';
import '../providers/auth_provider.dart';

/// Écran de verrouillage plein écran affiché quand l'app revient au premier
/// plan après plus de 60 s en arrière-plan (comptes gérant / PIN uniquement).
///
/// La vérification du PIN est locale (empreinte en secure storage) et
/// fonctionne donc HORS LIGNE. PIN correct → l'overlay disparaît et
/// l'utilisateur retrouve exactement l'écran (et le panier) où il était.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinControllers = List.generate(4, (_) => TextEditingController());
  final _pinFocusNodes = List.generate(4, (_) => FocusNode());
  bool _checking = false;

  String get _pin => _pinControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _clearPin() {
    for (final c in _pinControllers) {
      c.clear();
    }
    if (mounted) _pinFocusNodes.first.requestFocus();
  }

  Future<void> _submit() async {
    if (_pin.length != 4 || _checking) return;
    setState(() => _checking = true);
    final ok = await ref.read(appLockProvider.notifier).unlock(_pin);
    if (!mounted) return;
    setState(() => _checking = false);
    if (!ok) {
      AppSnackbar.error(context, 'Code PIN incorrect. Réessayez.');
      _clearPin();
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter avec votre numéro et votre code PIN. '
          'Les données non synchronisées seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: const Icon(
                      Symbols.lock,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const VGap(AppSpacing.xl),
                  const Text(
                    'Caisse verrouillée',
                    style: AppTextStyles.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const VGap(AppSpacing.sm),
                  Text(
                    user != null
                        ? '${user.nom}, saisissez votre code PIN pour continuer'
                        : 'Saisissez votre code PIN pour continuer',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const VGap(AppSpacing.xxxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        child: SizedBox(
                          width: 56,
                          height: 64,
                          child: TextField(
                            controller: _pinControllers[i],
                            focusNode: _pinFocusNodes[i],
                            autofocus: i == 0,
                            enabled: !_checking,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTextStyles.headlineLarge,
                            decoration: const InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMd,
                                borderSide:
                                    BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMd,
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (val) {
                              if (val.length == 1 && i < 3) {
                                _pinFocusNodes[i + 1].requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                _pinFocusNodes[i - 1].requestFocus();
                              }
                              if (_pin.length == 4) _submit();
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const VGap(AppSpacing.xl),
                  if (_checking)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  const VGap(AppSpacing.huge),
                  TextButton(
                    onPressed: _checking ? null : _confirmLogout,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
