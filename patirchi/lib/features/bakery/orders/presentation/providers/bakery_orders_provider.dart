import 'package:flutter/foundation.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class BakeryOrderItem {
  final int id;
  final String productName;
  final int qty;
  final int unitPrice;

  const BakeryOrderItem({
    required this.id,
    required this.productName,
    required this.qty,
    required this.unitPrice,
  });

  int get total => qty * unitPrice;

  factory BakeryOrderItem.fromApiJson(Map<String, dynamic> json) {
    final priceRaw = json['price']?.toString() ?? '0';
    final price = (double.tryParse(priceRaw) ?? 0).toInt();

    // product may be a nested object or a string name
    final productRaw = json['product'];
    String productName;
    if (productRaw is Map<String, dynamic>) {
      productName = productRaw['name'] as String? ?? '';
    } else {
      productName = productRaw?.toString() ?? '';
    }

    return BakeryOrderItem(
      id: json['id'] as int? ?? 0,
      productName: productName,
      qty: json['quantity'] as int? ?? 0,
      unitPrice: price,
    );
  }
}

class BakeryOrderCustomer {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const BakeryOrderCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory BakeryOrderCustomer.fromJson(Map<String, dynamic> json) {
    return BakeryOrderCustomer(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }
}

class BakeryOrder {
  final String id;
  final String orderNumber;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final List<BakeryOrderItem> items;
  final DeliveryMethod deliveryMethod;
  final String? deliveryAddress;
  final String paymentMethod;
  final bool isPaid;
  final OrderStatus status;
  final String? firstImage;
  final int? totalQuantity;

  const BakeryOrder({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.deliveryMethod,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
    this.firstImage,
    this.totalQuantity,
  });

  int get totalPrice => items.fold(0, (sum, item) => sum + item.total);

  BakeryOrder copyWith({OrderStatus? status}) {
    return BakeryOrder(
      id: id,
      orderNumber: orderNumber,
      date: date,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      isPaid: isPaid,
      status: status ?? this.status,
      firstImage: firstImage,
      totalQuantity: totalQuantity,
    );
  }

  /// Backend API javobidan parse qiladi.
  ///
  /// `GET /site/store/orders/` javob formati:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "status": "pending",
  ///   "total_price": "31000.00",
  ///   "items": [...],
  ///   "created_at": "2026-04-16T09:15:00Z",
  ///   "customer": {"id": 5, "first_name": "Alisher", "last_name": "Karimov", "phone_number": "901234567"},
  ///   "total_quantity": 7,
  ///   "first_image": "https://..."
  /// }
  /// ```
  factory BakeryOrder.fromApiJson(Map<String, dynamic> json) {
    final customerData = json['customer'];
    String customerName = '';
    String customerPhone = '';
    if (customerData is Map<String, dynamic>) {
      final customer = BakeryOrderCustomer.fromJson(customerData);
      customerName = customer.fullName;
      customerPhone = customer.phoneNumber;
    }

    final itemsRaw = json['items'] as List? ?? [];
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map(BakeryOrderItem.fromApiJson)
        .toList();

    DateTime date;
    try {
      date = DateTime.parse(json['created_at'] as String? ?? '');
    } on FormatException {
      date = DateTime.now();
    }

    final statusStr = json['status'] as String? ?? 'pending';
    final status = _parseStatus(statusStr);

    final idRaw = json['id'];
    final id = idRaw is int ? idRaw.toString() : (idRaw?.toString() ?? '0');

    return BakeryOrder(
      id: id,
      orderNumber: id,
      date: date,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      deliveryMethod: DeliveryMethod.courier,
      paymentMethod: '',
      isPaid: false,
      status: status,
      firstImage: json['first_image'] as String?,
      totalQuantity: json['total_quantity'] as int?,
    );
  }

  static OrderStatus _parseStatus(String s) {
    return switch (s) {
      'pending' => OrderStatus.pending,
      'confirmed' => OrderStatus.confirmed,
      'preparing' => OrderStatus.preparing,
      'delivering' => OrderStatus.delivering,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

class BakeryOrdersProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BakeryOrder> _orders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BakeryOrder> get orders => List.unmodifiable(_orders);

  // ---------------------------------------------------------------------------
  // Init — API dan yuklash
  // ---------------------------------------------------------------------------

  /// Barcha buyurtmalarni API dan yuklaydi.
  ///
  /// Agar API xato qaytarsa, mock data ishlatiladi.
  Future<void> loadOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (status != null) params['status'] = status;

      final response = await ApiClient.instance.get(
        ApiEndpoints.storeOrders,
        queryParams: params.isEmpty ? null : params,
      );
      final results = response['results'] as List? ?? [];
      _orders = results
          .whereType<Map<String, dynamic>>()
          .map(BakeryOrder.fromApiJson)
          .toList();
    } on Object catch (e) {
      _error = e.toString();
      // Xato bo'lsa mock data bilan davom etamiz
      _orders = _mockOrders;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<BakeryOrder> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  BakeryOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } on StateError {
      return null;
    }
  }

  int get todayOrderCount {
    final today = DateTime.now();
    return _orders.where((o) {
      return o.date.year == today.year &&
          o.date.month == today.month &&
          o.date.day == today.day &&
          o.status != OrderStatus.cancelled;
    }).length;
  }

  int get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where((o) =>
            o.date.year == today.year &&
            o.date.month == today.month &&
            o.date.day == today.day &&
            o.status == OrderStatus.delivered)
        .fold(0, (sum, o) => sum + o.totalPrice);
  }

  int get averageOrderValue {
    final delivered =
        _orders.where((o) => o.status == OrderStatus.delivered).toList();
    if (delivered.isEmpty) return 0;
    final total = delivered.fold(0, (sum, o) => sum + o.totalPrice);
    return total ~/ delivered.length;
  }

  // ---------------------------------------------------------------------------
  // Status o'zgartirish (lokal — backend endpoint yo'q)
  // ---------------------------------------------------------------------------

  // TODO(backend): Backend order status update endpointini qo'shgach,
  // bu metodlarni API chaqiruvlari bilan almashtirish kerak.
  // Taxminiy endpoint: PATCH /site/store/orders/<id>/
  // yoki POST /site/store/orders/<id>/confirm/ kabi action endpoint.

  void _updateStatus(String id, OrderStatus newStatus) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  void confirmOrder(String id) => _updateStatus(id, OrderStatus.confirmed);
  void rejectOrder(String id) => _updateStatus(id, OrderStatus.cancelled);
  void startPreparing(String id) => _updateStatus(id, OrderStatus.preparing);
  void markReady(String id) => _updateStatus(id, OrderStatus.delivering);
  void markDelivered(String id) => _updateStatus(id, OrderStatus.delivered);

  // ---------------------------------------------------------------------------
  // Mock fallback data
  // ---------------------------------------------------------------------------

  static final List<BakeryOrder> _mockOrders = [
    BakeryOrder(
      id: '1',
      orderNumber: '1001',
      date: DateTime(2026, 4, 16, 9, 15),
      customerName: 'Alisher Karimov',
      customerPhone: '901234567',
      items: const [
        BakeryOrderItem(
          id: 1,
          productName: 'Qoqon patir',
          qty: 5,
          unitPrice: 5000,
        ),
        BakeryOrderItem(
          id: 2,
          productName: 'Tandir non',
          qty: 2,
          unitPrice: 3000,
        ),
      ],
      deliveryMethod: DeliveryMethod.courier,
      deliveryAddress: 'Toshkent, Yunusobod, 12-kvartal',
      paymentMethod: 'Naqd pul',
      isPaid: false,
      status: OrderStatus.pending,
    ),
    BakeryOrder(
      id: '2',
      orderNumber: '1002',
      date: DateTime(2026, 4, 16, 10, 30),
      customerName: 'Malika Yusupova',
      customerPhone: '912345678',
      items: const [
        BakeryOrderItem(
          id: 3,
          productName: 'Somsa',
          qty: 10,
          unitPrice: 2000,
        ),
      ],
      deliveryMethod: DeliveryMethod.pickup,
      paymentMethod: 'Karta',
      isPaid: true,
      status: OrderStatus.confirmed,
    ),
    BakeryOrder(
      id: '3',
      orderNumber: '1003',
      date: DateTime(2026, 4, 16, 11, 0),
      customerName: 'Jasur Toshmatov',
      customerPhone: '931234567',
      items: const [
        BakeryOrderItem(
          id: 4,
          productName: 'Patir non',
          qty: 3,
          unitPrice: 5000,
        ),
        BakeryOrderItem(
          id: 5,
          productName: 'Gul non',
          qty: 1,
          unitPrice: 7000,
        ),
      ],
      deliveryMethod: DeliveryMethod.courier,
      deliveryAddress: 'Toshkent, Chilonzor, 9-mavze',
      paymentMethod: 'Click',
      isPaid: true,
      status: OrderStatus.preparing,
    ),
    BakeryOrder(
      id: '4',
      orderNumber: '1004',
      date: DateTime(2026, 4, 15, 14, 20),
      customerName: 'Nodira Rahimova',
      customerPhone: '941234567',
      items: const [
        BakeryOrderItem(
          id: 6,
          productName: 'Qoqon patir',
          qty: 8,
          unitPrice: 5000,
        ),
      ],
      deliveryMethod: DeliveryMethod.courier,
      deliveryAddress: 'Toshkent, Mirzo Ulugbek, 5-dom',
      paymentMethod: 'Payme',
      isPaid: true,
      status: OrderStatus.delivering,
    ),
    BakeryOrder(
      id: '5',
      orderNumber: '1005',
      date: DateTime(2026, 4, 15, 16, 45),
      customerName: 'Bobur Ismoilov',
      customerPhone: '951234567',
      items: const [
        BakeryOrderItem(
          id: 7,
          productName: 'Tandirda pishirilgan somsa',
          qty: 20,
          unitPrice: 2500,
        ),
        BakeryOrderItem(
          id: 8,
          productName: 'Non',
          qty: 5,
          unitPrice: 3000,
        ),
      ],
      deliveryMethod: DeliveryMethod.pickup,
      paymentMethod: 'Naqd pul',
      isPaid: true,
      status: OrderStatus.delivered,
    ),
    BakeryOrder(
      id: '6',
      orderNumber: '1006',
      date: DateTime(2026, 4, 14, 9, 10),
      customerName: 'Dilnoza Qosimova',
      customerPhone: '961234567',
      items: const [
        BakeryOrderItem(
          id: 9,
          productName: 'Patir non',
          qty: 4,
          unitPrice: 5000,
        ),
      ],
      deliveryMethod: DeliveryMethod.courier,
      deliveryAddress: 'Toshkent, Shayxontohur, 7-uy',
      paymentMethod: 'Karta',
      isPaid: false,
      status: OrderStatus.cancelled,
    ),
  ];
}

