import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/remote/shop_api.dart';
import '../models/shop_product.dart';

/// Catalogue boutique.
///
/// Le catalogue bon à tirer vient du backend (ainsi la gestion admin du stock
/// se répercute sur l'app). En cas d'échec réseau, on retombe sur le catalogue
/// statique embarqué avec ses stocks de départ.
final shopCatalogProvider = FutureProvider<List<ShopProduct>>((ref) async {
  try {
    final remote = await ref.watch(shopApiProvider).getProduits(actifs: true);
    if (remote.isNotEmpty) return remote.map(_toShopProduct).toList();
  } catch (_) {
    // Hors-ligne ou API indisponible → catalogue embarqué.
  }
  return List.of(kShopProducts);
});

ProductCategory _categoryFrom(String value) {
  switch (value) {
    case 'IMPRIMANTES':
      return ProductCategory.printers;
    case 'ROULEAUX':
      return ProductCategory.rolls;
    default:
      return ProductCategory.accessories;
  }
}

IconData _iconFrom(String value) {
  switch (value) {
    case 'receipt':
      return Symbols.receipt;
    case 'tablet_mac':
      return Symbols.tablet_mac;
    case 'barcode_scanner':
      return Symbols.barcode_scanner;
    case 'payments':
      return Symbols.payments;
    case 'router':
      return Symbols.router;
    case 'watch':
      return Symbols.watch;
    case 'memory':
      return Symbols.memory;
    default:
      return Symbols.print;
  }
}

Color _accentFor(ProductCategory category) {
  switch (category) {
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

ShopProduct _toShopProduct(ShopApiProduit p) {
  final category = _categoryFrom(p.categorie);
  return ShopProduct(
    id: p.id,
    name: p.nom,
    description: p.description,
    tagline: p.tagline,
    price: p.prix,
    oldPrice: p.ancienPrix,
    category: category,
    icon: _iconFrom(p.icone),
    specs: p.specs,
    isNew: p.isNew,
    isPopular: p.isPopulaire,
    stock: p.stock,
    accent: _accentFor(category),
  );
}