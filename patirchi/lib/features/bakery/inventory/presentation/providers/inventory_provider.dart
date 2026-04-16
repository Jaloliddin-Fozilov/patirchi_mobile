import 'package:flutter/foundation.dart';
import '../../data/models/inventory_item_model.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItemModel> _items = [
    InventoryItemModel(
      id: '1',
      name: 'Un (premium)',
      currentStock: 48.0,
      minStock: 50.0,
      unit: 'kg',
      lastRestocked: DateTime(2026, 4, 10),
      supplierId: 'sup1',
    ),
    InventoryItemModel(
      id: '2',
      name: 'Shakar',
      currentStock: 20.0,
      minStock: 15.0,
      unit: 'kg',
      lastRestocked: DateTime(2026, 4, 12),
      supplierId: 'sup1',
    ),
    InventoryItemModel(
      id: '3',
      name: "Paxta yog'i",
      currentStock: 8.0,
      minStock: 10.0,
      unit: 'litr',
      lastRestocked: DateTime(2026, 4, 8),
      supplierId: 'sup2',
    ),
    InventoryItemModel(
      id: '4',
      name: 'Tuz',
      currentStock: 12.0,
      minStock: 5.0,
      unit: 'kg',
      lastRestocked: DateTime(2026, 4, 5),
    ),
    InventoryItemModel(
      id: '5',
      name: 'Tuxum',
      currentStock: 60.0,
      minStock: 50.0,
      unit: 'dona',
      lastRestocked: DateTime(2026, 4, 14),
    ),
    InventoryItemModel(
      id: '6',
      name: 'Sut',
      currentStock: 3.0,
      minStock: 10.0,
      unit: 'litr',
      lastRestocked: DateTime(2026, 4, 11),
      supplierId: 'sup3',
    ),
    InventoryItemModel(
      id: '7',
      name: 'Xamirturush (quruq)',
      currentStock: 0.8,
      minStock: 2.0,
      unit: 'kg',
      lastRestocked: DateTime(2026, 4, 7),
    ),
    InventoryItemModel(
      id: '8',
      name: 'Sedana (zira)',
      currentStock: 1.5,
      minStock: 1.0,
      unit: 'kg',
      lastRestocked: DateTime(2026, 4, 9),
      supplierId: 'sup2',
    ),
  ];

  List<InventoryItemModel> get items => List.unmodifiable(_items);

  List<InventoryItemModel> get criticalItems =>
      _items.where((i) => i.stockStatus == StockStatus.critical).toList();

  List<InventoryItemModel> get lowItems =>
      _items.where((i) => i.stockStatus == StockStatus.low).toList();

  int get criticalCount => criticalItems.length;
  int get lowCount => lowItems.length;
  int get totalCount => _items.length;

  void updateStock(String id, double newQty) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(
      currentStock: newQty,
      lastRestocked: DateTime.now(),
    );
    notifyListeners();
  }

  void orderSupply(String id) {
    // In a real app this would navigate or open a form
    // For now just marks as if a restock is happening
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = _items[idx];
    _items[idx] = item.copyWith(
      currentStock: item.minStock * 2,
      lastRestocked: DateTime.now(),
    );
    notifyListeners();
  }
}
