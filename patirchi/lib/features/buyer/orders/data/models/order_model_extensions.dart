import 'package:patirchi/features/buyer/home/data/models/product_model.dart';
import 'order_model.dart';

/// [OrderModel] va [OrderItemModel] uchun qo'shimcha kengaytmalar.
///
/// [fromJson] / [toJson] metodlari endi to'g'ridan-to'g'ri model sinflarida.
/// Bu fayl product-based builder sifatida saqlanadi.

extension OrderItemModelHelpers on OrderItemModel {
  /// [ProductModel] dan [OrderItemModel] yaratadi (checkout uchun).
  static OrderItemModel fromProduct(ProductModel product, int quantity) {
    return OrderItemModel(
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': itemId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}

extension OrderModelHelpers on OrderModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'total_price': totalPrice,
        'delivery_fee': deliveryFee,
        'discount': discount,
        'created_at': createdAt.toIso8601String(),
        'shop_name': shopName,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        if (estimatedDelivery != null)
          'estimated_delivery': estimatedDelivery!.toIso8601String(),
      };
}
