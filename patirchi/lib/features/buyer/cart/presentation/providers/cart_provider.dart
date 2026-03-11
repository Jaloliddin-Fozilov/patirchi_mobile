import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _couponCode;
  DeliveryMethod _deliveryMethod = DeliveryMethod.pickup;

  List<CartItemModel> get items => _items;
  DeliveryMethod get deliveryMethod => _deliveryMethod;
  String? get couponCode => _couponCode;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee =>
      _deliveryMethod == DeliveryMethod.courier ? 15000 : 0;

  int get discount => _couponCode != null ? (subtotal * 0.1).round() : 0;

  int get total => subtotal - discount + deliveryFee;

  void addItem(ProductModel product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx != -1) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      if (qty <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity = qty;
      }
      notifyListeners();
    }
  }

  void setDeliveryMethod(DeliveryMethod method) {
    _deliveryMethod = method;
    notifyListeners();
  }

  void applyCoupon(String code) {
    _couponCode = code.isNotEmpty ? code : null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _couponCode = null;
    notifyListeners();
  }
}
