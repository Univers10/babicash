import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';

/// Numéro WhatsApp BabiCash (format international sans '+').
const kWhatsAppNumber = '2250714998984';

/// Formate un montant en FCFA avec séparateur de milliers : 12 500 FCFA.
String formatFCFA(num amount) {
  final digits = amount.round().toString();
  final parts = <String>[];
  for (var i = digits.length; i > 0; i -= 3) {
    final start = i - 3 < 0 ? 0 : i - 3;
    parts.insert(0, digits.substring(start, i));
  }
  return '${parts.join(' ')} FCFA';
}

enum ProductCategory { printers, rolls, accessories, all }

extension ProductCategoryLabel on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.printers:
        return 'Imprimantes';
      case ProductCategory.rolls:
        return 'Rouleaux';
      case ProductCategory.accessories:
        return 'Accessoires';
      case ProductCategory.all:
        return 'Tout';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.printers:
        return Symbols.print;
      case ProductCategory.rolls:
        return Symbols.receipt;
      case ProductCategory.accessories:
        return Symbols.tablet_mac;
      case ProductCategory.all:
        return Symbols.grid_view;
    }
  }

  Color get accent {
    switch (this) {
      case ProductCategory.printers:
        return AppColors.primary;
      case ProductCategory.rolls:
        return AppColors.accentDark;
      case ProductCategory.accessories:
        return AppColors.brown;
      case ProductCategory.all:
        return AppColors.textPrimary;
    }
  }
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    this.tagline = '',
    this.oldPrice,
    this.specs = const [],
    this.isNew = false,
    this.isPopular = false,
    this.stock = 0,
    this.accent = AppColors.primary,
  });

  final String id;
  final String name;
  final String description;
  final String tagline;
  final double price;
  final double? oldPrice;
  final ProductCategory category;
  final IconData icon;
  final List<String> specs;
  final bool isNew;
  final bool isPopular;
  final int stock;
  final Color accent;

  bool get hasPromo => oldPrice != null && oldPrice! > price;

  bool get outOfStock => stock <= 0;

  int get promoPercent =>
      hasPromo ? (((oldPrice! - price) / oldPrice!) * 100).round() : 0;

  String get priceLabel => formatFCFA(price);

  String get oldPriceLabel => hasPromo ? formatFCFA(oldPrice!) : '';
}

/// Une ligne du panier boutique.
class ShopCartLine {
  const ShopCartLine({required this.product, required this.quantity});

  final ShopProduct product;
  final int quantity;

  double get subtotal => product.price * quantity;

  String get subtotalLabel => formatFCFA(subtotal);
}

const kShopProducts = [
  ShopProduct(
    id: 'imp-thermal-58',
    stock: 12,
    name: 'Imprimante thermique 58 mm',
    tagline: 'Bluetooth · Batterie',
    description:
        'Connexion Bluetooth, batterie longue autonomie, idéale pour les reçus en boutique.',
    specs: ['Bluetooth', '58 mm', 'Batterie incluse', 'Impression rapide'],
    price: 25000,
    oldPrice: 30000,
    category: ProductCategory.printers,
    icon: Symbols.print,
    isPopular: true,
    accent: AppColors.primary,
  ),
  ShopProduct(
    id: 'imp-thermal-80',
    stock: 8,
    name: 'Imprimante thermique 80 mm',
    tagline: 'Débit rapide · Silencieuse',
    description:
        'Plus rapide et plus silencieuse, pensée pour les points de vente à fort volume.',
    specs: ['USB + Bluetooth', '80 mm', 'Silencieuse', 'Haute vitesse'],
    price: 45000,
    category: ProductCategory.printers,
    icon: Symbols.print,
    isNew: true,
    accent: AppColors.primaryLight,
  ),
  ShopProduct(
    id: 'rolls-58-10',
    stock: 50,
    name: 'Rouleaux 58 mm x 10',
    tagline: 'Qualité supérieure · 14 m',
    description: 'Papier thermique de qualité supérieure, 10 rouleaux de 14 m.',
    specs: ['10 rouleaux', '14 m', 'Papier thermique'],
    price: 2500,
    oldPrice: 3000,
    category: ProductCategory.rolls,
    icon: Symbols.receipt,
    isPopular: true,
    accent: AppColors.accentDark,
  ),
  ShopProduct(
    id: 'rolls-80-10',
    stock: 40,
    name: 'Rouleaux 80 mm x 10',
    tagline: 'Haute densité · 25 m',
    description: 'Papier thermique 80 mm haute densité, 10 rouleaux de 25 m.',
    specs: ['10 rouleaux', '25 m', 'Haute densité'],
    price: 4000,
    oldPrice: 5000,
    category: ProductCategory.rolls,
    icon: Symbols.receipt,
    accent: AppColors.accentDark,
  ),
  ShopProduct(
    id: 'stand-tablet',
    stock: 15,
    name: 'Support tablette / smartphone',
    tagline: 'Antivol · Orientable',
    description:
        'Support antivol orientable pour caisse mobile, fixe ou de comptoir.',
    specs: ['Antivol', 'Rotation 360°', 'Compatible tablette & téléphone'],
    price: 12000,
    category: ProductCategory.accessories,
    icon: Symbols.tablet_mac,
    isNew: true,
    accent: AppColors.brown,
  ),
  ShopProduct(
    id: 'scanner-bt',
    stock: 10,
    name: 'Lecteur code-barres Bluetooth',
    tagline: 'Scan rapide · Sans fil',
    description:
        'Scan rapide des produits en boutique et réduction des erreurs de saisie.',
    specs: ['Bluetooth', 'Scan rapide', 'Batterie longue durée'],
    price: 18000,
    category: ProductCategory.accessories,
    icon: Symbols.barcode_scanner,
    isPopular: true,
    accent: AppColors.brown,
  ),
  ShopProduct(
    id: 'cash-drawer',
    stock: 6,
    name: 'Tiroir-caisse connecté',
    tagline: 'Ouverture auto à chaque reçu',
    description:
        'S\'ouvre automatiquement à l\'impression du reçu. Compatible avec tous les modèles BabiCash.',
    specs: ['Ouverture auto', 'Compatible 58 / 80 mm'],
    price: 22000,
    oldPrice: 25000,
    category: ProductCategory.accessories,
    icon: Symbols.payments,
    accent: AppColors.primaryDark,
  ),
];