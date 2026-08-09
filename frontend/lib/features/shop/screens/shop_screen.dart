import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/menu_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/shop_product.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ProductCategory _category = ProductCategory.all;

  Future<void> _order(ShopProduct product) async {
    final nom = ref.read(authStateProvider).value?.nom;
    final message = 'Bonjour BabiCash,\n'
        'Je souhaite commander le produit suivant :\n'
        '${product.name}\n'
        'Prix : ${product.price.toStringAsFixed(0)} FCFA\n'
        '${nom != null && nom.isNotEmpty ? 'Nom : $nom\n' : ''}'
        'Merci de me contacter pour finaliser la commande.';
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
    final filtered = _category == ProductCategory.all
        ? kShopProducts
        : kShopProducts.where((p) => p.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Boutique'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          const _ShopHeader(),
          const VGap(AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final cat in ProductCategory.values)
                  _CategoryChip(
                    label: cat.label,
                    selected: _category == cat,
                    onTap: () => setState(() => _category = cat),
                  ),
              ],
            ),
          ),
          const VGap(AppSpacing.lg),
          for (final product in filtered) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ProductCard(
                product: product,
                onOrder: () => _order(product),
              ),
            ),
            const VGap(AppSpacing.lg),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: _DeliveryNotice(),
          ),
        ],
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

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
              Symbols.shopping_bag,
              color: AppColors.onPrimary,
              size: 26,
            ),
          ),
          const VGap(AppSpacing.lg),
          Text(
            'Matériel de travail',
            style: AppTextStyles.displayMedium
                .copyWith(color: AppColors.onPrimary),
          ),
          const VGap(AppSpacing.sm),
          Text(
            'Commandez vos imprimantes, rouleaux et accessoires directement via WhatsApp.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onOrder});

  final ShopProduct product;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  product.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const HGap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.headlineSmall,
                    ),
                    const VGap(2),
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.amountMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const VGap(AppSpacing.md),
          Text(
            product.description,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const VGap(AppSpacing.lg),
          AppButton(
            label: 'Commander par WhatsApp',
            icon: Symbols.chat,
            onPressed: onOrder,
          ),
        ],
      ),
    );
  }
}

class _DeliveryNotice extends StatelessWidget {
  const _DeliveryNotice();

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
              const Icon(
                Symbols.local_shipping,
                size: 18,
                color: AppColors.primary,
              ),
              const HGap(AppSpacing.sm),
              Text(
                'Livraison & paiement',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const VGap(AppSpacing.sm),
          Text(
            'Paiement et retrait organisés par WhatsApp. Livraison possible selon votre zone.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
