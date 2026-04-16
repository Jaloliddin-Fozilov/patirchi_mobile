import 'package:flutter/material.dart';
import 'package:patirchi/features/buyer/address/data/models/address_model.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';
import 'package:patirchi/core/constants/enums.dart';

enum PaymentMethod {
  cash,
  payme,
  click,
  uzum;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Naqd pul';
      case PaymentMethod.payme:
        return 'Payme';
      case PaymentMethod.click:
        return 'Click';
      case PaymentMethod.uzum:
        return 'Uzum Bank';
    }
  }

  String get iconAsset {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.payme:
        return 'payme';
      case PaymentMethod.click:
        return 'click';
      case PaymentMethod.uzum:
        return 'uzum';
    }
  }
}

class CheckoutProvider extends ChangeNotifier {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  AddressModel? _selectedAddress;
  bool _isProcessing = false;
  String? _placedOrderNumber;

  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isProcessing => _isProcessing;
  String? get placedOrderNumber => _placedOrderNumber;

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setAddress(AddressModel? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<OrderModel?> placeOrder(CartProvider cart) async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final orderNumber =
        '1${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    _placedOrderNumber = orderNumber;

    final order = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      items: cart.items
          .where((item) => item.product != null)
          .map((item) => OrderItemModel(
                productName: item.product!.name,
                quantity: item.quantity,
                unitPrice: item.product!.price,
              ))
          .toList(),
      status: OrderStatus.pending,
      totalPrice: cart.total,
      deliveryFee: cart.deliveryFee,
      discount: cart.discount,
      createdAt: DateTime.now(),
      shopName: 'Toshkent Non',
      deliveryAddress: _selectedAddress?.fullAddress,
      paymentMethod: _selectedPaymentMethod.label,
      estimatedDelivery:
          cart.deliveryMethod == DeliveryMethod.courier
              ? DateTime.now().add(const Duration(minutes: 45))
              : null,
    );

    cart.clear();

    _isProcessing = false;
    notifyListeners();

    return order;
  }

  void reset() {
    _selectedPaymentMethod = PaymentMethod.cash;
    _selectedAddress = null;
    _isProcessing = false;
    _placedOrderNumber = null;
    notifyListeners();
  }
}
