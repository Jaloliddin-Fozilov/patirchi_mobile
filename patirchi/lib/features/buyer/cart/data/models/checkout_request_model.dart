import 'package:patirchi/core/constants/enums.dart';

/// Buyurtma berish (checkout) so'rovi modeli.
///
/// [CartProvider.checkout] va [CartRepository.checkout] tomonidan ishlatiladi.
class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.deliveryMethod,
    this.addressId,
    this.couponCode,
    required this.paymentMethod,
  });

  /// Savatcka elementlari — `{ product_id, quantity }` ro'yxati.
  final List<CheckoutItem> items;

  /// Yetkazib berish usuli.
  final DeliveryMethod deliveryMethod;

  /// Manzil identifikatori (kuryer tanlanganda majburiy).
  final String? addressId;

  /// Kupon kodi (ixtiyoriy).
  final String? couponCode;

  /// To'lov usuli.
  final PaymentMethod paymentMethod;

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'delivery_method': deliveryMethod.name,
        if (addressId != null) 'address_id': addressId,
        if (couponCode != null) 'coupon_code': couponCode,
        'payment_method': paymentMethod.name,
      };

  @override
  String toString() =>
      'CheckoutRequest(items: ${items.length}, method: ${deliveryMethod.name})';
}

/// Buyurtmadagi bitta mahsulot elementi.
class CheckoutItem {
  const CheckoutItem({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

/// To'lov usullari.
enum PaymentMethod {
  cash,
  card,
  online;

  String get label {
    return switch (this) {
      PaymentMethod.cash => 'Naqd pul',
      PaymentMethod.card => 'Karta',
      PaymentMethod.online => 'Online to\'lov',
    };
  }
}
