// Delivery status strings matching backend state machine
// pending → accepted → picked_up → delivered | cancelled
class DeliveryOrderModel {
  final int id;
  final String status; // pending/accepted/picked_up/delivered/cancelled
  final int deliveryFee; // parsed from decimal string
  final double? distanceKm;
  final String? notes;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String customerPhone;
  final int totalPrice; // parsed from decimal string
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const DeliveryOrderModel({
    required this.id,
    required this.status,
    required this.deliveryFee,
    this.distanceKm,
    this.notes,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.customerPhone,
    required this.totalPrice,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.createdAt,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      deliveryFee:
          (double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0)
              .toInt(),
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString())
          : null,
      notes: json['notes'] as String?,
      storeName: json['store_name'] as String? ?? '',
      storeAddress: json['store_address'] as String? ?? '',
      storePhone: json['store_phone'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      totalPrice:
          (double.tryParse(json['total_price']?.toString() ?? '0') ?? 0)
              .toInt(),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.tryParse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  DeliveryOrderModel copyWith({
    int? id,
    String? status,
    int? deliveryFee,
    double? distanceKm,
    String? notes,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? customerPhone,
    int? totalPrice,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      distanceKm: distanceKm ?? this.distanceKm,
      notes: notes ?? this.notes,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      customerPhone: customerPhone ?? this.customerPhone,
      totalPrice: totalPrice ?? this.totalPrice,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'accepted':
        return 'Qabul qilindi';
      case 'picked_up':
        return 'Olib ketildi';
      case 'delivered':
        return 'Yetkazildi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return status;
    }
  }

  String get distanceLabel {
    if (distanceKm != null) {
      return '${distanceKm!.toStringAsFixed(1)} km';
    }
    return '';
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPickedUp => status == 'picked_up';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => status == 'accepted' || status == 'picked_up';
}

class DeliveryProfile {
  final int id;
  final String transportType;
  final String transportTypeDisplay;
  final bool isAvailable;
  final double rating;
  final int totalDeliveries;
  final int totalEarnings; // parsed from decimal
  final bool isVerified;
  final String phoneNumber;

  const DeliveryProfile({
    required this.id,
    required this.transportType,
    required this.transportTypeDisplay,
    required this.isAvailable,
    required this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.isVerified,
    required this.phoneNumber,
  });

  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      id: json['id'] as int,
      transportType: json['transport_type'] as String? ?? 'walking',
      transportTypeDisplay:
          json['transport_type_display'] as String? ?? 'Piyoda',
      isAvailable: json['is_available'] as bool? ?? false,
      rating: (double.tryParse(json['rating']?.toString() ?? '0') ?? 0),
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      totalEarnings:
          (double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0)
              .toInt(),
      isVerified: json['is_verified'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }

  DeliveryProfile copyWith({
    int? id,
    String? transportType,
    String? transportTypeDisplay,
    bool? isAvailable,
    double? rating,
    int? totalDeliveries,
    int? totalEarnings,
    bool? isVerified,
    String? phoneNumber,
  }) {
    return DeliveryProfile(
      id: id ?? this.id,
      transportType: transportType ?? this.transportType,
      transportTypeDisplay: transportTypeDisplay ?? this.transportTypeDisplay,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
