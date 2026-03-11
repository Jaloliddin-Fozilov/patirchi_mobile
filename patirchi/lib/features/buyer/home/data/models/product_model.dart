class ProductModel {
  final String id;
  final String name;
  final int price;
  final int? oldPrice;
  final int? discountPercent;
  final String? imageUrl;
  final double weight;
  final String weightUnit;
  final List<String> ingredients;
  final String description;
  final String shopId;
  final String shopName;
  final String? categoryId;
  final bool isAvailable;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.oldPrice,
    this.discountPercent,
    this.imageUrl,
    this.weight = 0,
    this.weightUnit = 'dona',
    this.ingredients = const [],
    this.description = '',
    this.shopId = '',
    this.shopName = '',
    this.categoryId,
    this.isAvailable = true,
    this.isFavorite = false,
  });
}
