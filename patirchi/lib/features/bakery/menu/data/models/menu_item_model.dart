import 'package:patirchi/core/models/product_category_model.dart';

/// Bakery mahsulot modeli.
///
/// [fromApiJson] — backend list/detail javobini parse qiladi.
/// [fromJson] — lokal mock JSON uchun (backward compat).
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final int? oldPrice;
  final String category;
  final int? categoryId;
  final double weight;
  final String weightUnit;
  final List<String> ingredients;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.category,
    this.categoryId,
    required this.weight,
    required this.weightUnit,
    this.ingredients = const [],
    this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
  });

  MenuItemModel copyWith({
    String? name,
    String? description,
    int? price,
    int? oldPrice,
    String? category,
    int? categoryId,
    double? weight,
    String? weightUnit,
    List<String>? ingredients,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MenuItemModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
    );
  }

  /// Backend API javobidan parse qiladi.
  ///
  /// `GET /site/products/?store_id=X` javob formati:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "name": "Qoqon Patir",
  ///   "description": "...",
  ///   "price": "5000.00",
  ///   "weight": 500,
  ///   "is_available": true,
  ///   "ingredients": "Un, Yog'",
  ///   "first_image": "https://...",
  ///   "category": {"id": 2, "name": "Patir", "icon": null},
  ///   "created_at": "2026-01-01T00:00:00Z"
  /// }
  /// ```
  factory MenuItemModel.fromApiJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    ProductCategory? cat;
    if (categoryData is Map<String, dynamic>) {
      cat = ProductCategory.fromJson(categoryData);
    }

    // Narxni decimal stringdan int ga o'tkazish
    final priceRaw = json['price']?.toString() ?? '0';
    final price = (double.tryParse(priceRaw) ?? 0).toInt();

    // Ingredientlar string yoki list bo'lishi mumkin
    List<String> ingredients = const [];
    final ingRaw = json['ingredients'];
    if (ingRaw is String && ingRaw.isNotEmpty) {
      ingredients = ingRaw.split(',').map((s) => s.trim()).toList();
    } else if (ingRaw is List) {
      ingredients = ingRaw.map((e) => e.toString()).toList();
    }

    // Weight gramm yoki null
    final weightRaw = json['weight'];
    final double weight;
    if (weightRaw is num) {
      weight = weightRaw.toDouble();
    } else if (weightRaw is String) {
      weight = double.tryParse(weightRaw) ?? 0.0;
    } else {
      weight = 0.0;
    }

    // first_image URL
    final firstImage = json['first_image'] as String?;

    final idRaw = json['id'];
    final id = idRaw is int ? idRaw.toString() : (idRaw?.toString() ?? '0');

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String? ?? '');
    } on FormatException {
      createdAt = DateTime.now();
    }

    return MenuItemModel(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      category: cat?.name ?? '',
      categoryId: cat?.id,
      weight: weight,
      weightUnit: 'g',
      ingredients: ingredients,
      imageUrl: firstImage,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  /// Lokal mock JSON uchun (backward compat).
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      oldPrice: json['oldPrice'] as int?,
      category: json['category'] as String,
      weight: (json['weight'] as num).toDouble(),
      weightUnit: json['weightUnit'] as String,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'category': category,
      'weight': weight,
      'weightUnit': weightUnit,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
