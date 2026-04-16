import 'package:patirchi/core/models/product_category_model.dart';
import 'package:patirchi/core/models/store_model.dart';

/// Ta'minotchi mahsulot modeli.
///
/// [fromApiListJson] — `GET /site/supplier-products/` list javobini parse qiladi.
/// [fromApiDetailJson] — `GET /site/supplier-products/<id>/` detail javobini parse qiladi.
class SupplierProductModel {
  final int id;
  final String name;
  final String? description;
  final int price;
  final int? weight;
  final bool isAvailable;
  final String units;
  final String? firstImage;
  final StoreInfo? store;

  // Detail-only maydonlar
  final String? ingredients;
  final List<String>? images;
  final ProductCategory? category;

  // Lokal mock uchun saqlanadigan maydonlar
  final String? imageUrl;
  final bool isActive;

  const SupplierProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.weight,
    this.isAvailable = true,
    required this.units,
    this.firstImage,
    this.store,
    this.ingredients,
    this.images,
    this.category,
    this.imageUrl,
    this.isActive = true,
  });

  SupplierProductModel copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    int? weight,
    bool? isAvailable,
    String? units,
    String? firstImage,
    StoreInfo? store,
    String? ingredients,
    List<String>? images,
    ProductCategory? category,
    String? imageUrl,
    bool? isActive,
  }) {
    return SupplierProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      units: units ?? this.units,
      firstImage: firstImage ?? this.firstImage,
      store: store ?? this.store,
      ingredients: ingredients ?? this.ingredients,
      images: images ?? this.images,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  /// List endpoint javobidan parse qiladi.
  ///
  /// `GET /site/supplier-products/` javob formati:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "name": "Oliy nav un",
  ///   "price": "12000.00",
  ///   "weight": 1000,
  ///   "is_available": true,
  ///   "store": {"id": 3, "name": "Un Do'koni", ...},
  ///   "units": "kilogram",
  ///   "first_image": "https://..."
  /// }
  /// ```
  factory SupplierProductModel.fromApiListJson(Map<String, dynamic> json) {
    final priceRaw = json['price']?.toString() ?? '0';
    final price = (double.tryParse(priceRaw) ?? 0).toInt();

    final weightRaw = json['weight'];
    final int? weight;
    if (weightRaw is int) {
      weight = weightRaw;
    } else if (weightRaw is num) {
      weight = weightRaw.toInt();
    } else if (weightRaw is String) {
      weight = int.tryParse(weightRaw);
    } else {
      weight = null;
    }

    final storeData = json['store'];
    StoreInfo? store;
    if (storeData is Map<String, dynamic>) {
      store = StoreInfo.fromJson(storeData);
    }

    return SupplierProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: price,
      weight: weight,
      isAvailable: json['is_available'] as bool? ?? true,
      units: json['units'] as String? ?? 'piece',
      firstImage: json['first_image'] as String?,
      store: store,
      isActive: json['is_available'] as bool? ?? true,
    );
  }

  /// Detail endpoint javobidan parse qiladi.
  ///
  /// `GET /site/supplier-products/<id>/` — list maydonlarga qo'shimcha:
  /// description, ingredients, images, category
  factory SupplierProductModel.fromApiDetailJson(Map<String, dynamic> json) {
    final base = SupplierProductModel.fromApiListJson(json);

    final categoryData = json['category'];
    ProductCategory? cat;
    if (categoryData is Map<String, dynamic>) {
      cat = ProductCategory.fromJson(categoryData);
    }

    List<String>? images;
    final imagesRaw = json['images'];
    if (imagesRaw is List) {
      images = imagesRaw
          .whereType<Map<String, dynamic>>()
          .map((img) => img['image'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return base.copyWith(
      description: json['description'] as String?,
      ingredients: json['ingredients'] as String?,
      images: images,
      category: cat,
    );
  }

  /// Lokal mock JSON uchun (backward compat — eski maydon nomlari).
  factory SupplierProductModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '0') ?? 0;
    return SupplierProductModel(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: json['pricePerUnit'] as int? ?? 0,
      units: json['unit'] as String? ?? 'piece',
      isAvailable: json['isActive'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'weight': weight,
      'is_available': isAvailable,
      'units': units,
      'first_image': firstImage ?? imageUrl,
      'isActive': isActive,
    };
  }
}
