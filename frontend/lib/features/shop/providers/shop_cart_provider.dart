import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_product.dart';

/// Panier de la boutique (Matériel & accessoires).
/// État purement local : la commande part ensuite via WhatsApp.
class ShopCartNotifier extends Notifier<List<ShopCartLine>> {
  @override
  List<ShopCartLine> build() => [];

  int _indexOf(String productId) =>
      state.indexWhere((line) => line.product.id == productId);

  void add(ShopProduct product) {
    final i = _indexOf(product.id);
    if (i >= 0) {
      final line = state[i];
      state = [
        for (var j = 0; j < state.length; j++)
          if (j == i) ShopCartLine(product: product, quantity: line.quantity + 1) else state[j],
      ];
    } else {
      state = [...state, ShopCartLine(product: product, quantity: 1)];
    }
  }

  void increment(ShopProduct product) => add(product);

  void decrement(ShopProduct product) {
    final i = _indexOf(product.id);
    if (i < 0) return;
    final line = state[i];
    if (line.quantity <= 1) {
      remove(product);
      return;
    }
    state = [
      for (var j = 0; j < state.length; j++)
        if (j == i) ShopCartLine(product: product, quantity: line.quantity - 1) else state[j],
    ];
  }

  int quantityOf(String productId) {
    final i = _indexOf(productId);
    return i >= 0 ? state[i].quantity : 0;
  }

  void remove(ShopProduct product) {
    state = [
      for (final line in state)
        if (line.product.id != product.id) line,
    ];
  }

  void clear() => state = [];

  int get totalCount =>
      state.fold(0, (sum, line) => sum + line.quantity);

  double get totalAmount =>
      state.fold(0.0, (sum, line) => sum + line.subtotal);
}

final shopCartProvider =
    NotifierProvider<ShopCartNotifier, List<ShopCartLine>>(ShopCartNotifier.new);