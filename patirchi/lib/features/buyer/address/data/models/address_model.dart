class AddressModel {
  final String id;
  final String label;
  final String street;
  final String building;
  final String? apartment;
  final String? floor;
  final String? entrance;
  final String? comment;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.building,
    this.apartment,
    this.floor,
    this.entrance,
    this.comment,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  String get fullAddress {
    final parts = [street, 'uy $building'];
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add('kvartira $apartment');
    }
    if (floor != null && floor!.isNotEmpty) {
      parts.add('$floor-qavat');
    }
    return parts.join(', ');
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? street,
    String? building,
    String? apartment,
    String? floor,
    String? entrance,
    String? comment,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      floor: floor ?? this.floor,
      entrance: entrance ?? this.entrance,
      comment: comment ?? this.comment,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      building: json['building'] as String,
      apartment: json['apartment'] as String?,
      floor: json['floor'] as String?,
      entrance: json['entrance'] as String?,
      comment: json['comment'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'building': building,
      'apartment': apartment,
      'floor': floor,
      'entrance': entrance,
      'comment': comment,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
