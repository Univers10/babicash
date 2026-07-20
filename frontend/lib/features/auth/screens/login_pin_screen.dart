import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPinScreen extends ConsumerStatefulWidget {
  const LoginPinScreen({super.key});

  @override
  ConsumerState<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends ConsumerState<LoginPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telCtrl = TextEditingController();
  final _pinControllers = List.generate(4, (_) => TextEditingController());
  final _pinFocusNodes = List.generate(4, (_) => FocusNode());

  String get _pin =>
      _pinControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _prefillTelephone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Arrivée suite à une session expirée : informer l'utilisateur.
      if (ref.read(sessionExpiredProvider) == LoginMethod.pin) {
        AppSnackbar.info(
          context,
          'Session expirée. Saisissez votre code PIN pour continuer.',
        );
      }
    });
  }

  /// Préremplit le numéro depuis le secure storage (dernier login PIN).
  Future<void> _prefillTelephone() async {
    final telephone = await ref.read(secureStorageProvider).getTelephone();
    if (!mounted || telephone == null || telephone.isEmpty) return;
    if (_telCtrl.text.isEmpty) {
      setState(() => _telCtrl.text = telephone);
      // Le numéro est déjà là : l'utilisateur n'a plus que le PIN à saisir.
      _pinFocusNodes.first.requestFocus();
    }
  }

  @override
  void dispose() {
    _telCtrl.dispose();
    for (final c in _pinControllers) { c.dispose(); }
    for (final f in _pinFocusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pin.length != 4) {
      AppSnackbar.error(context, 'Saisissez votre code PIN à 4 chiffres.');
      return;
    }
    await ref.read(authStateProvider.notifier).loginPin(
          _telCtrl.text.trim(),
          _pin,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      if (next is AsyncError) {
        final err = next.error;
        final msg = err is AppException ? err.message : 'PIN ou numéro incorrect.';
        AppSnackbar.error(context, msg);
      }
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connexion gérant'),
        leading: BackButton(
          // Après une redirection (session expirée), il n'y a rien à
          // dépiler : retour explicite à l'écran de connexion.
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VGap(AppSpacing.xl),

                // Icône gérant
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: const Icon(
                      Symbols.person,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const VGap(AppSpacing.xl),

                const Center(
                  child: Text('Gérant', style: AppTextStyles.headlineLarge),
                ),
                const VGap(AppSpacing.sm),
                Center(
                  child: Text(
                    'Entrez votre numéro et code PIN',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const VGap(AppSpacing.xxxl),

                // Téléphone
                AppTextField(
                  controller: _telCtrl,
                  label: 'Numéro de téléphone',
                  hint: '07 00 00 00 00',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Symbols.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Numéro requis';
                    return null;
                  },
                ),
                const VGap(AppSpacing.xl),

                // PIN 4 chiffres
                const Text('Code PIN', style: AppTextStyles.labelLarge),
                const VGap(AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: SizedBox(
                        width: 56,
                        height: 64,
                        child: TextFormField(
                          controller: _pinControllers[i],
                          focusNode: _pinFocusNodes[i],
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
                              borderSide: BorderSide(color: AppColors.border),
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
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const VGap(AppSpacing.xxxl),

                AppButton(
                  label: 'Se connecter',
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: Symbols.login,
                ),
                const VGap(AppSpacing.huge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
