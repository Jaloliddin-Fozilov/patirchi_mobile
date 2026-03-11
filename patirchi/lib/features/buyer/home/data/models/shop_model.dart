class ShopModel {
  final String id;
  final String name;
  final String ownerName;
  final String? logoUrl;
  final List<String> images;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final String address;
  final String district;
  final double? latitude;
  final double? longitude;
  final double rating;
  final String shopType; // bakery / supplier
  final String status; // active, pending, inactive, blocked

  const ShopModel({
    required this.id,
    required this.name,
    this.ownerName = '',
    this.logoUrl,
    this.images = const [],
    this.isOpen = true,
    this.openTime = '08:00',
    this.closeTime = '22:00',
    this.address = '',
    this.district = '',
    this.latitude,
    this.longitude,
    this.rating = 4.5,
    this.shopType = 'bakery',
    this.status = 'active',
  });
}
