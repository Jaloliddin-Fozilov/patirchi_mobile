import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/buyer/cart/data/models/cart_item_model.dart';
import 'package:patirchi/features/buyer/cart/data/repositories/cart_repository.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartRepository? repository})
      : _repository = repository ?? CartRepository();

  final CartRepository _repository;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<CartItemModel> _items = [];
  DeliveryMethod _deliveryMethod = DeliveryMethod.pickup;
  String? _couponCode;
  bool _isLoading = false;
  String? _error;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<CartItemModel> get items => _items;
  DeliveryMethod get deliveryMethod => _deliveryMethod;
  String? get couponCode => _couponCode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee =>
      _deliveryMethod == DeliveryMethod.courier ? 15000 : 0;

  int get discount => _couponCode != null ? (subtotal * 0.1).round() : 0;

  int get total => subtotal - discount + deliveryFee;

  // ---------------------------------------------------------------------------
  // Load cart from API
  // ---------------------------------------------------------------------------

  Future<void> loadCart() async {
    _setLoading(true);
    final result = await _repository.getCart();
    result.fold(
      onSuccess: (cartModel) {
        _items = cartModel.items;
        _error = null;
      },
      onError: (failure) {
        _error = failure.message;
      },
    );
    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Add item
  // ---------------------------------------------------------------------------

  /// Mahsulotni savatchaga qo'shadi va savatchani yangilaydi.
  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    _setLoading(true);

    // Optimistic local update
    final existingIdx = _items.indexWhere((i) => i.product?.id == product.id);
    if (existingIdx != -1) {
      _items[existingIdx].quantity += quantity;
      notifyListeners();
    } else {
      // Temporary local item (id=0 until server responds)
      _items.add(CartItemModel(id: 0, product: product, quantity: quantity));
      notifyListeners();
    }

    final result = await _repository.addToCart(product.id, quantity);
    result.fold(
      onSuccess: (_) async {
        // Refresh from server to get real cart item IDs
        await _refreshCart();
      },
      onError: (failure) {
        // Rollback optimistic update
        if (existingIdx != -1) {
          _items[existingIdx].quantity -= quantity;
          if (_items[existingIdx].quantity <= 0) {
            _items.removeAt(existingIdx);
          }
        } else {
          _items.removeWhere((i) => i.product?.id == product.id && i.id == 0);
        }
        _error = failure.message;
      },
    );

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Remove item
  // ---------------------------------------------------------------------------

  /// Savatcha elementini o'chiradi.
  ///
  /// [productId] — ProductModel.id (int). Savatcha elementining id'si
  /// topiladi va serverga yuboriladi.
  Future<void> removeItem(int productId) async {
    final idx = _items.indexWhere((i) => i.product?.id == productId);
    if (idx == -1) return;

    final cartItemId = _items[idx].id;
    final removed = _items.removeAt(idx);
    notifyListeners();

    if (cartItemId == 0) return; // local-only item

    final result = await _repository.removeFromCart(cartItemId);
    result.fold(
      onSuccess: (_) {},
      onError: (failure) {
        // Rollback
        _items.insert(idx, removed);
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Update quantity
  // ---------------------------------------------------------------------------

  /// Savatcha elementining miqdorini yangilaydi.
  ///
  /// [productId] — ProductModel.id (int).
  /// [qty] <= 0 bo'lsa element o'chiriladi.
  Future<void> updateQuantity(int productId, int qty) async {
    final idx = _items.indexWhere((i) => i.product?.id == productId);
    if (idx == -1) return;

    if (qty <= 0) {
      await removeItem(productId);
      return;
    }

    final cartItemId = _items[idx].id;
    final oldQty = _items[idx].quantity;
    _items[idx].quantity = qty;
    notifyListeners();

    if (cartItemId == 0) return; // local-only item

    final result = await _repository.updateQuantity(cartItemId, qty);
    result.fold(
      onSuccess: (_) {},
      onError: (failure) {
        // Rollback
        _items[idx].quantity = oldQty;
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Checkout
  // ---------------------------------------------------------------------------

  /// Aktiv savatchadan buyurtma yaratadi.
  Future<OrderModel?> checkout() async {
    _setLoading(true);
    OrderModel? order;

    final result = await _repository.checkout();
    result.fold(
      onSuccess: (newOrder) {
        order = newOrder;
        _items.clear();
        _couponCode = null;
        _error = null;
      },
      onError: (failure) {
        _error = failure.message;
      },
    );

    _setLoading(false);
    return order;
  }

  // ---------------------------------------------------------------------------
  // Local-only helpers
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _refreshCart() async {
    final result = await _repository.getCart();
    result.fold(
      onSuccess: (cartModel) {
        _items = cartModel.items;
      },
      onError: (_) {},
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
