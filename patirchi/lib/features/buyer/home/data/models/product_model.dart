class ProductImage {
  final int id;
  final String image;
  final int order;

  const ProductImage({
    required this.id,
    required this.image,
    required this.order,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String? icon;

  const ProductCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

class StoreInfo {
  final int id;
  final String name;
  final String? logo;
  final String? address;
  final String? phoneNumber;

  const StoreInfo({
    required this.id,
    required this.name,
    this.logo,
    this.address,
    this.phoneNumber,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final int? weight; // grams
  final String? ingredients;
  final bool isAvailable;
  final String? firstImage; // URL from list endpoint
  final List<ProductImage> images; // from detail endpoint
  final ProductCategory? category;
  final StoreInfo? store;
  bool isFavorite; // local-only state

  // Legacy compatibility fields (derived from backend data or kept for UI)
  String get shopName => store?.name ?? '';
  String get shopId => store?.id.toString() ?? '';
  String? get imageUrl => firstImage ?? (images.isNotEmpty ? images.first.image : null);

  // Legacy weight display (default to grams unit)
  double get weightDouble => (weight ?? 0).toDouble();
  String get weightUnit => weight != null ? 'g' : 'dona';

  // Legacy discount fields — not in backend, kept null
  int? get oldPrice => null;
  int? get discountPercent => null;

  /// Ingredients as a list, split by comma from the string field.
  List<String> get ingredientsList {
    if (ingredients == null || ingredients!.trim().isEmpty) return [];
    return ingredients!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.weight,
    this.ingredients,
    this.isAvailable = true,
    this.firstImage,
    this.images = const [],
    this.category,
    this.store,
    this.isFavorite = false,
  });

  /// Full detail from GET `/site/products/<id>/`
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parsePrice(json['price']),
      weight: (json['weight'] as num?)?.toInt(),
      ingredients: json['ingredients'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      firstImage: json['first_image'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? StoreInfo.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Minimal fields from GET /site/products/ list endpoint
  factory ProductModel.fromListJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      price: _parsePrice(json['price']),
      weight: (json['weight'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool? ?? true,
      firstImage: json['first_image'] as String?,
    );
  }

  static int _parsePrice(dynamic raw) => parsePrice(raw);

  /// Parses price from int, double, String ("5000.00"), or num.
  static int parsePrice(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) return double.tryParse(raw)?.toInt() ?? 0;
    if (raw is num) return raw.toInt();
    return 0;
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    int? weight,
    String? ingredients,
    bool? isAvailable,
    String? firstImage,
    List<ProductImage>? images,
    ProductCategory? category,
    StoreInfo? store,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      ingredients: ingredients ?? this.ingredients,
      isAvailable: isAvailable ?? this.isAvailable,
      firstImage: firstImage ?? this.firstImage,
      images: images ?? this.images,
      category: category ?? this.category,
      store: store ?? this.store,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
