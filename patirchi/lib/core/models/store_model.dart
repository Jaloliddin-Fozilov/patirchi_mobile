/// Do'kon ma'lumotlari modeli — bakery va supplier uchun umumiy.
///
/// `GET /site/stores/?menu=bakery` va `GET /site/stores/?menu=supplier`
/// javoblarini parse qilish uchun ishlatiladi.
class StoreInfo {
  final int id;
  final String name;
  final String? logo;
  final String phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? openingTime;
  final String? closingTime;
  final bool isOpen;
  final String storeType;
  final String status;

  const StoreInfo({
    required this.id,
    required this.name,
    this.logo,
    required this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.closingTime,
    this.isOpen = false,
    required this.storeType,
    required this.status,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      isOpen: json['is_open'] as bool? ?? false,
      storeType: json['store_type'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'phone_number': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_open': isOpen,
      'store_type': storeType,
      'status': status,
    };
  }
}
