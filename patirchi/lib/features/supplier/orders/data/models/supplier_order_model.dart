import 'package:patirchi/core/constants/enums.dart';

class SupplierOrderItem {
  final String productId;
  final String productName;
  final String unit;
  final double quantity;
  final int unitPrice;

  const SupplierOrderItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
  });

  int get total => (quantity * unitPrice).round();

  factory SupplierOrderItem.fromApiJson(Map<String, dynamic> json) {
    // supplier_product may be nested object or id
    final productRaw = json['supplier_product'];
    String productName;
    String productId;
    String unit = '';
    if (productRaw is Map<String, dynamic>) {
      productName = productRaw['name'] as String? ?? '';
      productId = (productRaw['id'] as int?)?.toString() ?? '0';
      unit = productRaw['units'] as String? ?? '';
    } else {
      productName = '';
      productId = productRaw?.toString() ?? '0';
    }

    final priceRaw = json['price']?.toString() ?? '0';
    final unitPrice = (double.tryParse(priceRaw) ?? 0).toInt();

    final qtyRaw = json['quantity'];
    final double quantity;
    if (qtyRaw is num) {
      quantity = qtyRaw.toDouble();
    } else if (qtyRaw is String) {
      quantity = double.tryParse(qtyRaw) ?? 0;
    } else {
      quantity = 0;
    }

    return SupplierOrderItem(
      productId: productId,
      productName: productName,
      unit: unit,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}

class SupplierOrderModel {
  final String id;
  final String orderNumber;
  final String bakeryName;
  final String bakeryAddress;
  final String bakeryPhone;
  final List<SupplierOrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String? note;
  final int? supplierTotal;
  final String? firstImage;
  final int? totalQuantity;

  const SupplierOrderModel({
    required this.id,
    required this.orderNumber,
    required this.bakeryName,
    required this.bakeryAddress,
    required this.bakeryPhone,
    required this.items,
    required this.status,
    required this.createdAt,
    this.note,
    this.supplierTotal,
    this.firstImage,
    this.totalQuantity,
  });

  int get total {
    if (supplierTotal != null) return supplierTotal!;
    return items.fold(0, (sum, item) => sum + item.total);
  }

  SupplierOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? bakeryName,
    String? bakeryAddress,
    String? bakeryPhone,
    List<SupplierOrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    String? note,
    int? supplierTotal,
    String? firstImage,
    int? totalQuantity,
  }) {
    return SupplierOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      bakeryName: bakeryName ?? this.bakeryName,
      bakeryAddress: bakeryAddress ?? this.bakeryAddress,
      bakeryPhone: bakeryPhone ?? this.bakeryPhone,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      supplierTotal: supplierTotal ?? this.supplierTotal,
      firstImage: firstImage ?? this.firstImage,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  /// Backend API javobidan parse qiladi.
  ///
  /// `GET /site/supplier/orders/` javob formati:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "status": "pending",
  ///   "items": [...],
  ///   "customer": {"id": 10, "first_name": "Non", "last_name": "Zavodi", "phone_number": "901234567"},
  ///   "total_quantity": 200,
  ///   "supplier_total": "2400000.00",
  ///   "first_image": "https://...",
  ///   "created_at": "2026-04-16T09:30:00Z"
  /// }
  /// ```
  factory SupplierOrderModel.fromApiJson(Map<String, dynamic> json) {
    final customerData = json['customer'];
    String bakeryName = '';
    String bakeryPhone = '';
    if (customerData is Map<String, dynamic>) {
      final firstName = customerData['first_name'] as String? ?? '';
      final lastName = customerData['last_name'] as String? ?? '';
      bakeryName = '$firstName $lastName'.trim();
      bakeryPhone = customerData['phone_number'] as String? ?? '';
    }

    final itemsRaw = json['items'] as List? ?? [];
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map(SupplierOrderItem.fromApiJson)
        .toList();

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String? ?? '');
    } on FormatException {
      createdAt = DateTime.now();
    }

    final statusStr = json['status'] as String? ?? 'pending';
    final status = _parseStatus(statusStr);

    final idRaw = json['id'];
    final id = idRaw is int ? idRaw.toString() : (idRaw?.toString() ?? '0');

    // supplier_total — Decimal string
    final supplierTotalRaw = json['supplier_total']?.toString();
    final int? supplierTotal;
    if (supplierTotalRaw != null) {
      supplierTotal = (double.tryParse(supplierTotalRaw) ?? 0).toInt();
    } else {
      supplierTotal = null;
    }

    return SupplierOrderModel(
      id: id,
      orderNumber: 'SUP-$id',
      bakeryName: bakeryName,
      bakeryAddress: '',
      bakeryPhone: bakeryPhone,
      items: items,
      status: status,
      createdAt: createdAt,
      supplierTotal: supplierTotal,
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
