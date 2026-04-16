import 'package:patirchi/features/buyer/home/data/models/product_model.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final bool isActive;
  final int totalPrice;

  const CartModel({
    required this.id,
    required this.items,
    this.isActive = true,
    required this.totalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: (json['id'] as num).toInt(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      totalPrice: _parsePrice(json['total_price']),
    );
  }

  static int _parsePrice(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return double.tryParse(raw)?.toInt() ?? 0;
    if (raw is num) return raw.toInt();
    return 0;
  }
}

class CartItemModel {
  final int id; // cart item ID (needed for update/remove)
  final ProductModel? product;
  int quantity;

  CartItemModel({
    required this.id,
    this.product,
    this.quantity = 1,
  });

  int get totalPrice => (product?.price ?? 0) * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    ProductModel? prod;
    if (json['product'] != null) {
      prod = ProductModel.fromJson(json['product'] as Map<String, dynamic>);
    }
    return CartItemModel(
      id: (json['id'] as num).toInt(),
      product: prod,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
