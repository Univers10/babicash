import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  final _idProprietaireCtrl = TextEditingController();
  bool _obscure = true;
  bool _useIdLogin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    _idProprietaireCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_useIdLogin) {
      await ref.read(authStateProvider.notifier).loginId(
            _idProprietaireCtrl.text.trim(),
            _mdpCtrl.text,
          );
    } else {
      await ref.read(authStateProvider.notifier).loginEmail(
            _emailCtrl.text.trim(),
            _mdpCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next is AsyncError) {
        final err = next.error;
        final msg = err is AppException ? err.message : 'Erreur de connexion.';
        AppSnackbar.error(context, msg);
      }
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const VGap(AppSpacing.huge),

                  // Logo / titre
                  _BabiCashLogo(),
                  const VGap(AppSpacing.xxxl),

                  // Titre
                  Text(
                    'Connexion',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const VGap(AppSpacing.sm),
                  Text(
                    'Espace propriétaire',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const VGap(AppSpacing.lg),

                  // Toggle login mode
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _useIdLogin = false),
                          borderRadius: AppSpacing.borderRadiusMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_useIdLogin
                                  ? AppColors.primaryContainer
                                  : Colors.transparent,
                              borderRadius: AppSpacing.borderRadiusMd,
                            ),
                            child: Text(
                              'Email',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: !_useIdLogin
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: !_useIdLogin
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _useIdLogin = true),
                          borderRadius: AppSpacing.borderRadiusMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _useIdLogin
                                  ? AppColors.primaryContainer
                                  : Colors.transparent,
                              borderRadius: AppSpacing.borderRadiusMd,
                            ),
                            child: Text(
                              'ID Propriétaire',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _useIdLogin
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: _useIdLogin
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VGap(AppSpacing.lg),

                  // Email ou ID propriétaire
                  if (!_useIdLogin)
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'votre@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Symbols.email,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    )
                  else
                    AppTextField(
                      controller: _idProprietaireCtrl,
                      label: 'ID Propriétaire',
                      hint: 'UUID (ex: 123e4567-e89b-12d3-a456-426614174000)',
                      prefixIcon: Symbols.key,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'ID requis';
                        if (v.trim().length != 36) return 'UUID invalide';
                        return null;
                      },
                    ),
                  const VGap(AppSpacing.lg),

                  // Mot de passe
                  AppTextField(
                    controller: _mdpCtrl,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    obscureText: _obscure,
                    prefixIcon: Symbols.lock,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Symbols.visibility : Symbols.visibility_off,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Mot de passe requis';
                      return null;
                    },
                  ),
                  const VGap(AppSpacing.xxl),

                  // Bouton connexion
                  AppButton(
                    label: 'Se connecter',
                    onPressed: _submit,
                    isLoading: isLoading,
                    icon: Symbols.login,
                  ),
                  const VGap(AppSpacing.xl),

                  // Lien PIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gérant ? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.loginPin),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Connexion par PIN'),
                      ),
                    ],
                  ),
                  const VGap(AppSpacing.md),

                  // Lien inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nouveau propriétaire ? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Créer un compte'),
                      ),
                    ],
                  ),
                  const VGap(AppSpacing.huge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BabiCashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: const Icon(
            Symbols.account_balance_wallet,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const HGap(AppSpacing.md),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Babi',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: 'Cash',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
