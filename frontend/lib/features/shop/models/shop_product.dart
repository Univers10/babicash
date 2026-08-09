import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Numéro WhatsApp BabiCash (format international sans '+').
const kWhatsAppNumber = '2250714998984';

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
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final IconData icon;
}

const kShopProducts = [
  ShopProduct(
    id: 'imp-thermal-58',
    name: 'Imprimante thermique 58 mm',
    description: 'Connexion Bluetooth, batterie longue autonomie, idéale pour les reçus.',
    price: 25000,
    category: ProductCategory.printers,
    icon: Symbols.print,
  ),
  ShopProduct(
    id: 'imp-thermal-80',
    name: 'Imprimante thermique 80 mm',
    description: 'Plus rapide et plus silencieuse, pour les points de vente à fort volume.',
    price: 45000,
    category: ProductCategory.printers,
    icon: Symbols.print,
  ),
  ShopProduct(
    id: 'rolls-58-10',
    name: 'Rouleaux 58 mm x 10',
    description: 'Papier thermique de qualité supérieure, 10 rouleaux de 14 m.',
    price: 2500,
    category: ProductCategory.rolls,
    icon: Symbols.receipt,
  ),
  ShopProduct(
    id: 'rolls-80-10',
    name: 'Rouleaux 80 mm x 10',
    description: 'Papier thermique 80 mm, 10 rouleaux de 25 m.',
    price: 4000,
    category: ProductCategory.rolls,
    icon: Symbols.receipt,
  ),
  ShopProduct(
    id: 'stand-tablet',
    name: 'Support tablette / smartphone',
    description: 'Support antivol orientable pour caisse mobile.',
    price: 12000,
    category: ProductCategory.accessories,
    icon: Symbols.tablet_mac,
  ),
  ShopProduct(
    id: 'scanner-bt',
    name: 'Lecteur code-barres Bluetooth',
    description: 'Scan rapide des produits et réduction des erreurs de saisie.',
    price: 18000,
    category: ProductCategory.accessories,
    icon: Symbols.barcode_scanner,
  ),
  ShopProduct(
    id: 'cash-drawer',
    name: 'Tiroir-caisse connecté',
    description: 'S\'ouvre automatiquement à l\'impression du reçu.',
    price: 22000,
    category: ProductCategory.accessories,
    icon: Symbols.payments,
  ),
];
