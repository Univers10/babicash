import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/abonnement_model.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/menu_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/plan_catalog.dart';
import '../providers/quota_provider.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _annuel = false;

  Future<void> _openWhatsApp(PlanDef plan) async {
    final nom = ref.read(authStateProvider).value?.nom;
    final prix = _annuel ? plan.prixAnnuel : plan.prixMensuel;
    final cycle = _annuel ? 'an' : 'mois';
    final message = 'Bonjour BabiCash,\n'
        'Je souhaite souscrire au plan ${plan.nom} '
        '(${AmountText.format(prix)} / $cycle).\n'
        '${nom != null && nom.isNotEmpty ? 'Nom : $nom\n' : ''}'
        'Merci de me contacter pour finaliser le paiement Mobile Money.';
    final uri = Uri.https('wa.me', '/$kWhatsAppNumber', {'text': message});

    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      AppSnackbar.error(
        context,
        'Impossible d\'ouvrir WhatsApp. Vérifiez qu\'il est installé.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isOwner = user?.isOwner ?? false;
    final abonnement = ref.watch(monPlanProvider).valueOrNull;
    final currentPlan =
        abonnement != null ? planFromAbonnement(abonnement) : null;
    final unknownPlan = abonnement != null && currentPlan == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Abonnement'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          const _PricingHeader(),
          const VGap(AppSpacing.xl),
          if (!isOwner) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ManagerBanner(),
            ),
            const VGap(AppSpacing.lg),
          ],
          _BillingToggle(
            annuel: _annuel,
            onChanged: (v) => setState(() => _annuel = v),
          ),
          if (unknownPlan) ...[
            const VGap(AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CurrentPlanBanner(abonnement: abonnement),
            ),
          ],
          const VGap(AppSpacing.xl),
          for (final plan in kPlansCatalog) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _PlanCard(
                plan: plan,
                annuel: _annuel,
                isCurrent: currentPlan?.id == plan.id,
                onChoose: () => _openWhatsApp(plan),
              ),
            ),
            const VGap(AppSpacing.lg),
          ],
          const VGap(AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TrustFooter(),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _PricingHeader extends StatelessWidget {
  const _PricingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXl),
          bottomRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.rocket_launch,
              color: AppColors.onPrimary,
              size: 26,
            ),
          ),
          const VGap(AppSpacing.lg),
          Text(
            'Passez au niveau supérieur',
            style: AppTextStyles.displayMedium
                .copyWith(color: AppColors.onPrimary),
          ),
          const VGap(AppSpacing.sm),
          Text(
            'Choisissez le plan qui grandit avec votre commerce.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

// ── Bannières ──────────────────────────────────────────────────────────────────

class _ManagerBanner extends StatelessWidget {
  const _ManagerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          const Icon(Symbols.lock, size: 18, color: AppColors.accentDark),
          const HGap(AppSpacing.sm),
          Expanded(
            child: Text(
              'Seul le propriétaire peut modifier l\'abonnement.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.onAccentContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanBanner extends StatelessWidget {
  const _CurrentPlanBanner({required this.abonnement});
  final AbonnementOut abonnement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          const Icon(Symbols.info, size: 18, color: AppColors.primary),
          const HGap(AppSpacing.sm),
          Expanded(
            child: Text(
              'Votre plan actuel : ${abonnement.plan} — '
              '${AmountText.format(abonnement.prixTotalMensuel)} / mois',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle mensuel / annuel ────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.annuel, required this.onChanged});
  final bool annuel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleSegment(
              label: 'Mensuel',
              selected: !annuel,
              onTap: () => onChanged(false),
            ),
            _ToggleSegment(
              label: 'Annuel',
              selected: annuel,
              badge: '-2 mois',
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusFull,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (badge != null) ...[
              const HGap(AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Carte plan ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.annuel,
    required this.isCurrent,
    required this.onChoose,
  });

  final PlanDef plan;
  final bool annuel;
  final bool isCurrent;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? AppColors.primary
        : plan.populaire
            ? AppColors.accent
            : AppColors.borderLight;

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(
          color: borderColor,
          width: isCurrent || plan.populaire ? 2 : 1,
        ),
        gradient: plan.populaire
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentContainer.withValues(alpha: 0.35),
                  AppColors.surface,
                ],
              )
            : null,
        boxShadow: plan.populaire
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: plan.populaire
                      ? AppColors.accentContainer
                      : AppColors.surfaceVariant,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  plan.icon,
                  color: plan.populaire
                      ? AppColors.accentDark
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const HGap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.nom, style: AppTextStyles.headlineMedium),
                    const VGap(2),
                    Text(
                      plan.tagline,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isCurrent) ...[
                const HGap(AppSpacing.sm),
                const _Chip(
                  label: 'Votre plan',
                  icon: Symbols.check_circle,
                  background: AppColors.primaryContainer,
                  foreground: AppColors.onPrimaryContainer,
                ),
              ],
            ],
          ),
          const VGap(AppSpacing.lg),
          _PriceBlock(plan: plan, annuel: annuel),
          const VGap(AppSpacing.lg),
          const Divider(height: 1),
          const VGap(AppSpacing.lg),
          for (final feature in plan.features) ...[
            _FeatureRow(label: feature),
            if (feature != plan.features.last) const VGap(AppSpacing.sm + 2),
          ],
          if (!plan.gratuit || isCurrent) ...[
            const VGap(AppSpacing.xl),
            if (isCurrent)
              const AppButton(
                label: 'Plan actuel',
                onPressed: null,
                variant: AppButtonVariant.outlined,
                icon: Symbols.check_circle,
              )
            else
              AppButton(
                label: 'Choisir ce plan',
                onPressed: onChoose,
                icon: Symbols.chat,
                variant: plan.populaire
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.primary,
              ),
          ],
        ],
      ),
    );

    if (!plan.populaire) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.star,
                      size: 14, color: Colors.white, fill: 1),
                  const HGap(AppSpacing.xs),
                  Text(
                    'POPULAIRE',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bloc prix ──────────────────────────────────────────────────────────────────

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.plan, required this.annuel});
  final PlanDef plan;
  final bool annuel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
      child: plan.gratuit
          ? Row(
              key: const ValueKey('gratuit'),
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('0 FCFA', style: AppTextStyles.amountLarge),
                const HGap(AppSpacing.sm),
                Text(
                  'pour toujours',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            )
          : annuel
              ? Column(
                  key: const ValueKey('annuel'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AmountText.format(plan.prixAnnuelBarre),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const VGap(2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          '${AmountText.format(plan.prixAnnuel)} / an',
                          style: AppTextStyles.amountLarge,
                        ),
                        const _Chip(
                          label: '2 mois offerts',
                          icon: Symbols.redeem,
                          background: AppColors.accentContainer,
                          foreground: AppColors.onAccentContainer,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('mensuel'),
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        AmountText.format(plan.prixMensuel),
                        style: AppTextStyles.amountLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const HGap(AppSpacing.sm),
                    Text(
                      '/ mois',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
    );
  }
}

// ── Éléments partagés ──────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground, fill: 1),
          const HGap(AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Symbols.check_circle,
          size: 18,
          color: AppColors.success,
          fill: 1,
        ),
        const HGap(AppSpacing.sm),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.verified_user,
                  size: 18, color: AppColors.primary, fill: 1),
              const HGap(AppSpacing.sm),
              Text(
                'Paiement sécurisé par Mobile Money',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const VGap(AppSpacing.sm),
          Text(
            'Orange Money, Wave, MTN MoMo, Moov Money. '
            'Activation sous 24 h après confirmation du paiement. '
            'Changez de plan à tout moment.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
