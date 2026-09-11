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
import '../providers/shop_cart_provider.dart';
import '../providers/shop_catalog_provider.dart';
import '../../../data/remote/shop_api.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();
  ProductCategory _category = ProductCategory.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopProduct> _filteredOf(List<ShopProduct> catalog) {
    final q = _query.trim().toLowerCase();
    return catalog.where((p) {
      final inCategory =
          _category == ProductCategory.all || p.category == _category;
      final inQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.tagline.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return inCategory && inQuery;
    }).toList();
  }

  Future<void> _orderOnWhatsApp(List<ShopCartLine> lines) async {
    final user = ref.read(authStateProvider).value;
    final nom = user?.nom;
    final total = lines.fold<double>(0, (s, l) => s + l.subtotal);
    final linesText = lines
        .map((l) =>
            '• ${l.product.name} x${l.quantity} — ${formatFCFA(l.subtotal)}')
        .join('\n');
    final namePart = (nom != null && nom.isNotEmpty) ? '\nNom : $nom' : '';
    final message = 'Bonjour BabiCash,\n'
        'Je souhaite commander :\n'
        '$linesText\n'
        '\n'
        'Total : ${formatFCFA(total)}'
        '$namePart\n'
        '\n'
        'Merci de me confirmer la livraison et le paiement de ma commande.';
    final uri =
        Uri.https('wa.me', '/$kWhatsAppNumber', {'text': message});

    // Enregistrement best-effort côté serveur (la commande WhatsApp continue
    // même hors-ligne). Le total / les prix sont recalculés par le backend.
    try {
      await ref.read(shopApiProvider).createCommande(
            clientNom: nom ?? 'Client boutique',
            lignes: lines.map(_toLignePayload).toList(),
          );
    } catch (_) {
      // Silencieux : WhatsApp reste le canal de commande.
    }

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
      return;
    }
    if (mounted) {
      AppSnackbar.success(
        context,
        'Commande envoyée ! Nous vous répondrons très vite.',
      );
      ref.read(shopCartProvider.notifier).clear();
    }
  }

  void _openProductDetails(ShopProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _ProductDetailsSheet(product: product),
    );
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _CartSheet(
        onOrder: _orderOnWhatsApp,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(shopCartProvider);
    final catalog = ref.watch(shopCatalogProvider).valueOrNull ?? kShopProducts;
    final cartCount = cart.fold<int>(0, (s, l) => s + l.quantity);
    final cartTotal = cart.fold<double>(0, (s, l) => s + l.subtotal);
    final products = _filteredOf(catalog);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Boutique'),
        actions: [
          _CartIconButton(
            badgeCount: cartCount,
            onTap: _openCart,
          ),
          const HGap(AppSpacing.sm),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                ),
                const VGap(AppSpacing.md),
                _PromoBanner(
                  onPromoTap: () => setState(
                    () => _category = ProductCategory.rolls,
                  ),
                ),
                const VGap(AppSpacing.lg),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _TrustBadges(),
                ),
                const VGap(AppSpacing.lg),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      for (final cat in ProductCategory.values) ...[
                        _CategoryChip(
                          label: cat.label,
                          icon: cat.icon,
                          accent: cat.accent,
                          count: catalog
                              .where((p) =>
                                  cat == ProductCategory.all ||
                                  p.category == cat)
                              .length,
                          selected: _category == cat,
                          onTap: () => setState(() => _category = cat),
                        ),
                        const HGap(AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
                const VGap(AppSpacing.xl),
              ],
            ),
          ),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                icon: _query.trim().isEmpty
                    ? Symbols.inventory_2
                    : Symbols.search_off,
                message: _query.trim().isEmpty
                    ? 'Aucun produit dans cette catégorie'
                    : 'Aucun résultat pour « ${_query.trim()} »',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 300,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ProductCard(
                    product: products[i],
                    onTap: () => _openProductDetails(products[i]),
                  ),
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: cartCount > 0
          ? _CartBar(
              count: cartCount,
              total: cartTotal,
              onTap: _openCart,
            )
          : null,
    );
  }
}

// ── AppBar : panier ─────────────────────────────────────────────────────────

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.badgeCount, required this.onTap});

  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Panier',
      icon: Badge(
        isLabelVisible: badgeCount > 0,
        backgroundColor: AppColors.accent,
        textColor: AppColors.onAccentContainer,
        label: Text('$badgeCount'),
        child: const Icon(Symbols.shopping_cart),
      ),
    );
  }
}

// ── Barre panier persistante ────────────────────────────────────────────────

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.accentContainer,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(
                  Symbols.shopping_cart,
                  size: 22,
                  color: AppColors.accentDark,
                ),
              ),
              const HGap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count article${count > 1 ? 's' : ''}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      formatFCFA(total),
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Voir le panier',
                icon: Symbols.shopping_cart,
                onPressed: onTap,
                compact: true,
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recherche ───────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un produit…',
        hintStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textTertiary),
        prefixIcon: const Icon(
          Symbols.search,
          size: 20,
          color: AppColors.textTertiary,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Symbols.close,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Bannière promotionnelle ─────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onPromoTap});

  final VoidCallback onPromoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  'OFFRE SPÉCIALE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onAccentContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const VGap(AppSpacing.md),
              Text(
                'Équipez votre point de vente',
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.onPrimary),
              ),
              const VGap(AppSpacing.xs),
              Text(
                'Imprimantes, rouleaux et accessoires au meilleur prix.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
              ),
              const VGap(AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '−25% sur les rouleaux thermiques',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.onPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: onPromoTap,
                    borderRadius: AppSpacing.borderRadiusFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.onPrimary,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        'Découvrir',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Réassurance ─────────────────────────────────────────────────────────────

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Symbols.local_shipping, 'Livraison\n48 – 72h'),
      (Symbols.verified_user, 'Paiement\nà la livraison'),
      (Symbols.headset_mic, 'Support\nWhatsApp 7j/7'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 28, color: AppColors.divider),
            Expanded(
              child: Column(
                children: [
                  Icon(items[i].$1, size: 22, color: AppColors.primary),
                  const VGap(4),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Chips catégories ────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: selected ? accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.onPrimary : accent,
            ),
            const HGap(6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const HGap(6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.onPrimary.withValues(alpha: 0.2)
                    : AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grille produits ─────────────────────────────────────────────────────────

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.onTap});

  final ShopProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(shopCartProvider);
    final quantity = _quantityOf(cart, product.id);

    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.borderRadiusLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 132,
              child: _ProductVisual(product: product),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall,
                    ),
                    const VGap(2),
                    Text(
                      product.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.hasPromo)
                          Text(
                            product.oldPriceLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          product.priceLabel,
                          style: AppTextStyles.headlineSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  if (product.outOfStock)
                    const _OutOfStockPill()
                  else if (quantity == 0)
                    _AddButton(onTap: () => ref.read(shopCartProvider.notifier).add(product))
                  else
                    _QtyStepper(
                      quantity: quantity,
                      onDec: () =>
                          ref.read(shopCartProvider.notifier).decrement(product),
                      onInc: () =>
                          ref.read(shopCartProvider.notifier).increment(product),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductVisual extends StatelessWidget {
  const _ProductVisual({required this.product});

  final ShopProduct product;

  String get _badge {
    if (product.outOfStock) return 'Rupture';
    if (product.hasPromo) return '−${product.promoPercent}%';
    if (product.isNew) return 'Nouveau';
    if (product.isPopular) return 'Populaire';
    return '';
  }

  Color get _badgeColor {
    if (product.outOfStock) return AppColors.textSecondary;
    if (product.hasPromo) return AppColors.error;
    if (product.isNew) return AppColors.primary;
    return AppColors.accentDark;
  }

  @override
  Widget build(BuildContext context) {
    final accent = product.accent;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.16),
                accent.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Icon(
            product.icon,
            size: 60,
            color: accent.withValues(alpha: 0.18),
          ),
        ),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(product.icon, size: 32, color: accent),
          ),
        ),
        if (_badge.isNotEmpty)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _badgeColor,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                _badge,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              product.category.icon,
              size: 14,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.add, size: 18, color: AppColors.onPrimary),
            const HGap(2),
            Text(
              'Ajouter',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutOfStockPill extends StatelessWidget {
  const _OutOfStockPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symbols.inventory_2,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const HGap(4),
          Text(
            'Rupture',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onDec,
    required this.onInc,
  });

  final int quantity;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperBtn(icon: Symbols.remove, onTap: onDec),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          _StepperBtn(icon: Symbols.add, onTap: onInc),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: SizedBox(
        width: 34,
        height: 36,
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

// ── Fiche produit ───────────────────────────────────────────────────────────

class _ProductDetailsSheet extends ConsumerWidget {
  const _ProductDetailsSheet({required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(shopCartProvider);
    final quantity = _quantityOf(cart, product.id);
    final inCart = quantity > 0;
    final height = MediaQuery.of(context).size.height * 0.78;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: _DragHandle(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 180,
                    child: _ProductVisual(product: product),
                  ),
                  const VGap(AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                  const VGap(AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        product.category.icon,
                        size: 16,
                        color: product.accent,
                      ),
                      const HGap(AppSpacing.xs),
                      Text(
                        product.category.label,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      if (product.isPopular) ...[
                        const Icon(
                          Symbols.bolt,
                          size: 14,
                          color: AppColors.accentDark,
                        ),
                        const HGap(2),
                        Text(
                          'Bestseller',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.accentDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const VGap(AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.hasPromo) ...[
                        Text(
                          product.oldPriceLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const HGap(AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            '−${product.promoPercent}%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const HGap(AppSpacing.sm),
                      ],
                      Text(
                        product.priceLabel,
                        style: AppTextStyles.amountLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (product.outOfStock) ...[
                    const VGap(AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Symbols.inventory_2,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const HGap(AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Produit momentanément en rupture de stock.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const VGap(AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Symbols.check_circle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const HGap(AppSpacing.xs),
                        Text(
                          'En stock',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const VGap(AppSpacing.lg),
                  Text(
                    'Caractéristiques',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const VGap(AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final spec in product.specs)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            spec,
                            style: AppTextStyles.labelMedium,
                          ),
                        ),
                    ],
                  ),
                  const VGap(AppSpacing.lg),
                  Text(
                    'Description',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const VGap(AppSpacing.xs),
                  Text(
                    product.description,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const VGap(AppSpacing.xl),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: SafeArea(
              top: false,
              child: product.outOfStock
                  ? const AppButton(
                      label: 'Rupture de stock',
                      icon: Symbols.inventory_2,
                      onPressed: null,
                      compact: true,
                    )
                  : Row(
                      children: [
                        _QtyStepper(
                          quantity: quantity,
                          onDec: () => ref
                              .read(shopCartProvider.notifier)
                              .decrement(product),
                          onInc: () => ref
                              .read(shopCartProvider.notifier)
                              .increment(product),
                        ),
                        const HGap(AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: inCart
                                ? 'Mettre à jour le panier'
                                : 'Ajouter au panier',
                            icon: inCart ? Symbols.shopping_cart : Symbols.add,
                            onPressed: () {
                              Navigator.of(context).pop();
                              AppSnackbar.success(
                                context,
                                inCart
                                    ? 'Panier mis à jour.'
                                    : '« ${product.name} » ajouté au panier.',
                              );
                            },
                            compact: true,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.border,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
    );
  }
}

// ── Panier ──────────────────────────────────────────────────────────────────

class _CartSheet extends ConsumerWidget {
  const _CartSheet({required this.onOrder, required this.onClose});

  final Future<void> Function(List<ShopCartLine> lines) onOrder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(shopCartProvider);
    final total = lines.fold<double>(0, (s, l) => s + l.subtotal);
    final toggleQty = ref.read(shopCartProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: _DragHandle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Votre commande',
                  style: AppTextStyles.headlineLarge,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Symbols.close,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (lines.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              children: [
                const Icon(
                  Symbols.shopping_cart,
                  size: 56,
                  color: AppColors.textDisabled,
                ),
                const VGap(AppSpacing.md),
                const Text(
                  'Votre panier est vide',
                  style: AppTextStyles.headlineMedium,
                ),
                const VGap(AppSpacing.xs),
                Text(
                  'Parcourez la boutique et ajoutez vos produits.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: lines.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _CartLine(
                line: lines[i],
                onDec: () => toggleQty.decrement(lines[i].product),
                onInc: () => toggleQty.increment(lines[i].product),
                onRemove: () {
                  toggleQty.remove(lines[i].product);
                  AppSnackbar.info(context, '« ${lines[i].product.name} » retiré.');
                },
              ),
            ),
          ),
        const VGap(AppSpacing.md),
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                  Text(
                    formatFCFA(total),
                    style: AppTextStyles.amountLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const VGap(4),
              const Row(
                children: [
                  Icon(
                    Symbols.local_shipping,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  HGap(4),
                  Text(
                    'Livraison et paiement confirmés par WhatsApp',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const VGap(AppSpacing.md),
              AppButton(
                label: 'Commander via WhatsApp',
                icon: Symbols.chat,
                onPressed: lines.isEmpty ? null : () => onOrder(lines),
                isLoading: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.line,
    required this.onDec,
    required this.onInc,
    required this.onRemove,
  });

  final ShopCartLine line;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final accent = line.product.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              line.product.icon,
              size: 26,
              color: accent,
            ),
          ),
          const HGap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const VGap(4),
                Row(
                  children: [
                    _QtyStepper(
                      quantity: line.quantity,
                      onDec: onDec,
                      onInc: onInc,
                    ),
                    const HGap(AppSpacing.md),
                    Text(
                      line.subtotalLabel,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Symbols.delete,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

int _quantityOf(List<ShopCartLine> cart, String productId) {
  for (final line in cart) {
    if (line.product.id == productId) return line.quantity;
  }
  return 0;
}

final _uuidPattern =
    RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

/// Construit la ligne à envoyer au backend (`POST /shop/commandes`).
///
/// Le `produit_id` n'est envoyé que pour les produits du catalogue distant
/// (uuid) : pour les produits statiques (fallback), le nom et le prix font foi
/// côté serveur.
Map<String, dynamic> _toLignePayload(ShopCartLine line) {
  return {
    if (_uuidPattern.hasMatch(line.product.id)) 'produit_id': line.product.id,
    'nom': line.product.name,
    'prix_unitaire': line.product.price,
    'quantite': line.quantity,
  };
}

// ── État vide ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textDisabled),
          const VGap(AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}