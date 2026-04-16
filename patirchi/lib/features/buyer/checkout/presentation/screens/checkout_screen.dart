import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';
import 'package:patirchi/features/buyer/address/presentation/providers/address_provider.dart';
import 'package:patirchi/features/buyer/orders/presentation/providers/orders_provider.dart';
import 'package:patirchi/features/buyer/checkout/presentation/providers/checkout_provider.dart';
import 'package:patirchi/features/buyer/address/presentation/screens/address_list_screen.dart';
import 'checkout_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addrProvider = context.read<AddressProvider>();
      final checkoutProvider = context.read<CheckoutProvider>();
      if (checkoutProvider.selectedAddress == null) {
        checkoutProvider.setAddress(addrProvider.selectedAddress);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buyurtma berish',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<CartProvider, CheckoutProvider>(
        builder: (context, cart, checkout, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _DeliverySection(cart: cart, checkout: checkout),
                    const SizedBox(height: 12),
                    _AddressSection(checkout: checkout),
                    const SizedBox(height: 12),
                    _OrderItemsSection(cart: cart),
                    const SizedBox(height: 12),
                    _CouponSection(cart: cart),
                    const SizedBox(height: 12),
                    _PaymentSummarySection(cart: cart),
                    const SizedBox(height: 12),
                    _PaymentMethodSection(checkout: checkout),
                  ],
                ),
              ),
              _BottomBar(cart: cart, checkout: checkout),
            ],
          );
        },
      ),
    );
  }
}

// ===== Delivery Method =====
class _DeliverySection extends StatelessWidget {
  final CartProvider cart;
  final CheckoutProvider checkout;

  const _DeliverySection({required this.cart, required this.checkout});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Yetkazish usuli',
      child: Row(
        children: DeliveryMethod.values.map((method) {
          final isSelected = cart.deliveryMethod == method;
          return Expanded(
            child: GestureDetector(
              onTap: () => cart.setDeliveryMethod(method),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                margin: EdgeInsets.only(
                  right: method == DeliveryMethod.pickup ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      method == DeliveryMethod.pickup
                          ? Icons.store_rounded
                          : Icons.delivery_dining_rounded,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      method.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (method == DeliveryMethod.courier)
                      Text(
                        '15,000 so\'m',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    if (method == DeliveryMethod.pickup)
                      Text(
                        'Bepul',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ===== Address =====
class _AddressSection extends StatelessWidget {
  final CheckoutProvider checkout;

  const _AddressSection({required this.checkout});

  @override
  Widget build(BuildContext context) {
    final address = checkout.selectedAddress;

    return _SectionCard(
      title: 'Manzil',
      trailing: TextButton(
        onPressed: () async {
          final selected = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddressListScreen(selectionMode: true),
            ),
          );
          if (selected != null && context.mounted) {
            context.read<CheckoutProvider>().setAddress(selected);
          }
        },
        child: const Text(
          'O\'zgartirish',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: address == null
          ? GestureDetector(
              onTap: () async {
                final selected = await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddressListScreen(selectionMode: true),
                  ),
                );
                if (selected != null && context.mounted) {
                  context.read<CheckoutProvider>().setAddress(selected);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_location_alt_outlined,
                        color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'Manzil qo\'shing',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address.fullAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ===== Order Items =====
class _OrderItemsSection extends StatelessWidget {
  final CartProvider cart;

  const _OrderItemsSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Buyurtma tarkibi',
      trailing: Text(
        '${cart.itemCount} ta',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      child: Column(
        children: cart.items.where((item) => item.product != null).map((item) {
          final product = item.product!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warmBg,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: const Icon(
                    Icons.bakery_dining,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${item.quantity} x ${Formatters.price(product.price)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.price(item.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ===== Coupon =====
class _CouponSection extends StatefulWidget {
  final CartProvider cart;

  const _CouponSection({required this.cart});

  @override
  State<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<_CouponSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.cart.couponCode != null;

    return _SectionCard(
      title: 'Kupon kodi',
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Masalan: PATIR20',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.confirmation_num_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.warmBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: hasDiscount
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              widget.cart.applyCoupon(_ctrl.text.trim());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Text(
                'Qo\'llash',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Payment Summary =====
class _PaymentSummarySection extends StatelessWidget {
  final CartProvider cart;

  const _PaymentSummarySection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'To\'lov xulosasi',
      child: Column(
        children: [
          _SummaryLine('Mahsulotlar', Formatters.price(cart.subtotal)),
          if (cart.discount > 0)
            _SummaryLine(
              'Chegirma',
              '-${Formatters.price(cart.discount)}',
              valueColor: AppColors.success,
            ),
          _SummaryLine(
            'Yetkazib berish',
            cart.deliveryFee > 0
                ? Formatters.price(cart.deliveryFee)
                : 'Bepul',
            valueColor: cart.deliveryFee == 0 ? AppColors.success : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jami to\'lov',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                Formatters.price(cart.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== Payment Method =====
class _PaymentMethodSection extends StatelessWidget {
  final CheckoutProvider checkout;

  const _PaymentMethodSection({required this.checkout});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'To\'lov usuli',
      child: Column(
        children: PaymentMethod.values.map((method) {
          final isSelected = checkout.selectedPaymentMethod == method;
          return GestureDetector(
            onTap: () => checkout.setPaymentMethod(method),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.warmBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  _PaymentIcon(method: method),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentIcon({required this.method});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (method) {
      PaymentMethod.cash => (Icons.payments_rounded, const Color(0xFF4CAF50)),
      PaymentMethod.payme => (Icons.credit_card_rounded, const Color(0xFF1EBDCE)),
      PaymentMethod.click => (Icons.touch_app_rounded, const Color(0xFF0066FF)),
      PaymentMethod.uzum => (Icons.account_balance_wallet_rounded, const Color(0xFF7B2FBE)),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ===== Bottom bar =====
class _BottomBar extends StatelessWidget {
  final CartProvider cart;
  final CheckoutProvider checkout;

  const _BottomBar({required this.cart, required this.checkout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: checkout.isProcessing
              ? null
              : () async {
                  final ordersProvider = context.read<OrdersProvider>();
                  final order = await checkout.placeOrder(cart);
                  if (order != null) {
                    ordersProvider.addOrder(order);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutSuccessScreen(
                            orderNumber: order.orderNumber,
                            orderId: order.id,
                          ),
                        ),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            elevation: 0,
          ),
          child: checkout.isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Buyurtma berish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.price(cart.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ===== Shared helpers =====
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryLine(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
