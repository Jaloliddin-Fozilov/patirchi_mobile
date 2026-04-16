/// Mahsulot kategoriyasi — `GET /site/categories/` javobini parse qiladi.
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
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}
