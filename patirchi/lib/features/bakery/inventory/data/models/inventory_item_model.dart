enum StockStatus { sufficient, low, critical }

class InventoryItemModel {
  final String id;
  final String name;
  final double currentStock;
  final double minStock;
  final String unit;
  final DateTime lastRestocked;
  final String? supplierId;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.lastRestocked,
    this.supplierId,
  });

  StockStatus get stockStatus {
    if (currentStock <= 0 || currentStock < minStock * 0.5) {
      return StockStatus.critical;
    } else if (currentStock < minStock) {
      return StockStatus.low;
    }
    return StockStatus.sufficient;
  }

  InventoryItemModel copyWith({
    double? currentStock,
    double? minStock,
    String? unit,
    DateTime? lastRestocked,
    String? supplierId,
  }) {
    return InventoryItemModel(
      id: id,
      name: name,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      supplierId: supplierId ?? this.supplierId,
    );
  }
}
