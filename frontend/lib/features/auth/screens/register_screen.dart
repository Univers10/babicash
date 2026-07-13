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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).register(
          _nomCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _mdpCtrl.text,
          _telephoneCtrl.text.trim().isEmpty ? null : _telephoneCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next is AsyncError) {
        final err = next.error;
        final msg = err is AppException ? err.message : 'Erreur d\'inscription.';
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
                    'Créer un compte',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const VGap(AppSpacing.sm),
                  Text(
                    'Espace propriétaire',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const VGap(AppSpacing.xxxl),

                  // Nom
                  AppTextField(
                    controller: _nomCtrl,
                    label: 'Nom complet',
                    hint: 'Votre nom',
                    prefixIcon: Symbols.person,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nom requis';
                      return null;
                    },
                  ),
                  const VGap(AppSpacing.lg),

                  // Email
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
                  ),
                  const VGap(AppSpacing.lg),

                  // Téléphone (optionnel)
                  AppTextField(
                    controller: _telephoneCtrl,
                    label: 'Téléphone (optionnel)',
                    hint: '+225 07...',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Symbols.phone,
                    textInputAction: TextInputAction.next,
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
                      if (v.length < 6) return 'Min. 6 caractères';
                      return null;
                    },
                  ),
                  const VGap(AppSpacing.xxl),

                  // Bouton inscription
                  AppButton(
                    label: 'Créer mon compte',
                    onPressed: _submit,
                    isLoading: isLoading,
                    icon: Symbols.person_add,
                  ),
                  const VGap(AppSpacing.xl),

                  // Lien connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Se connecter'),
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
