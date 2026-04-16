class ShopImage {
  final int id;
  final String image;
  final int order;

  const ShopImage({
    required this.id,
    required this.image,
    required this.order,
  });

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ShopModel {
  final int id;
  final String name;
  final String? logo; // full URL
  final String phoneNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final String openingTime; // "08:00:00"
  final String closingTime;
  final bool isOpen;
  final String storeType; // 'bakery' | 'supplier'
  final List<ShopImage> images;

  // Legacy UI compatibility
  String get openTime => _formatTime(openingTime);
  String get closeTime => _formatTime(closingTime);
  String get logoUrl => logo ?? '';
  String get shopType => storeType;
  double get rating => 4.5; // not in backend, kept for UI

  const ShopModel({
    required this.id,
    required this.name,
    this.logo,
    this.phoneNumber = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.openingTime = '08:00:00',
    this.closingTime = '22:00:00',
    this.isOpen = true,
    this.storeType = 'bakery',
    this.images = const [],
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      openingTime: json['opening_time'] as String? ?? '08:00:00',
      closingTime: json['closing_time'] as String? ?? '22:00:00',
      isOpen: json['is_open'] as bool? ?? true,
      storeType: json['store_type'] as String? ?? 'bakery',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ShopImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Format "08:00:00" → "08:00"
  static String _formatTime(String time) {
    if (time.length >= 5) return time.substring(0, 5);
    return time;
  }
}
