import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _activeMerchantId;

  Map<String, CartItem> get items => {..._items};
  String? get activeMerchantId => _activeMerchantId;
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, String merchantId) {
    if (_activeMerchantId != null && _activeMerchantId != merchantId) {
      // In a real app, you might show a dialog asking to clear the cart
      return;
    }
    
    _activeMerchantId = merchantId;
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
      if (_items.isEmpty) {
        _activeMerchantId = null;
      }
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _activeMerchantId = null;
    notifyListeners();
  }

  int getProductQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }
}
