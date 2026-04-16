import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';

class OrderItemModel {
  final int itemId; // server-side item ID
  final String productName;
  final int quantity;
  final int unitPrice; // snapshot price

  const OrderItemModel({
    this.itemId = 0,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get totalPrice => unitPrice * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // product may be a nested object or null
    String name = '';
    int price = 0;

    final productRaw = json['product'];
    if (productRaw is Map<String, dynamic>) {
      name = productRaw['name'] as String? ?? '';
      price = ProductModel.parsePrice(productRaw['price']);
    }

    // Some endpoints return unit price separately
    final rawPrice = json['price'] ?? json['unit_price'];
    if (rawPrice != null) {
      price = ProductModel.parsePrice(rawPrice);
    }

    return OrderItemModel(
      itemId: (json['id'] as num?)?.toInt() ?? 0,
      productName: name,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: price,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': itemId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}

class OrderModel {
  final String id; // kept as String for UI compatibility
  final String orderNumber;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final int totalPrice;
  final int deliveryFee;
  final int discount;
  final DateTime createdAt;
  final String shopName;
  final String? deliveryAddress;
  final String paymentMethod;
  final DateTime? estimatedDelivery;

  const OrderModel({
    required this.id,
    this.orderNumber = '',
    required this.items,
    required this.status,
    required this.totalPrice,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.createdAt,
    this.shopName = '',
    this.deliveryAddress,
    this.paymentMethod = 'cash',
    this.estimatedDelivery,
  });

  int get subtotal => totalPrice - deliveryFee + discount;

  String get itemsSummary {
    if (items.isEmpty) return '';
    if (items.length == 1) {
      return '${items.first.productName} x${items.first.quantity}';
    }
    return '${items.first.productName} va yana ${items.length - 1} ta mahsulot';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId is int ? rawId.toString() : (rawId as String? ?? '');

    return OrderModel(
      id: idStr,
      orderNumber: json['order_number'] as String? ?? idStr,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: _parseStatus(json['status'] as String?),
      totalPrice: ProductModel.parsePrice(json['total_price']),
      deliveryFee: ProductModel.parsePrice(json['delivery_fee'] ?? 0),
      discount: ProductModel.parsePrice(json['discount'] ?? 0),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      shopName: _extractShopName(json),
      deliveryAddress: json['delivery_address'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.tryParse(json['estimated_delivery'] as String)
          : null,
    );
  }

  static String _extractShopName(Map<String, dynamic> json) {
    // Try items[0].product.store.name
    final items = json['items'] as List<dynamic>?;
    if (items != null && items.isNotEmpty) {
      final first = items.first as Map<String, dynamic>?;
      final product = first?['product'] as Map<String, dynamic>?;
      final store = product?['store'] as Map<String, dynamic>?;
      if (store?['name'] is String) return store!['name'] as String;
    }
    return json['shop_name'] as String? ?? '';
  }

  static OrderStatus _parseStatus(String? value) {
    return switch (value) {
      'pending' => OrderStatus.pending,
      'confirmed' => OrderStatus.confirmed,
      'preparing' => OrderStatus.preparing,
      'delivering' => OrderStatus.delivering,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    List<OrderItemModel>? items,
    OrderStatus? status,
    int? totalPrice,
    int? deliveryFee,
    int? discount,
    DateTime? createdAt,
    String? shopName,
    String? deliveryAddress,
    String? paymentMethod,
    DateTime? estimatedDelivery,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      shopName: shopName ?? this.shopName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }
}
