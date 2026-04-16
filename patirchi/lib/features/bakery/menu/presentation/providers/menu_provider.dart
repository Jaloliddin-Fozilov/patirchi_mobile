import 'package:flutter/foundation.dart';
import 'package:patirchi/core/models/product_category_model.dart';
import 'package:patirchi/features/bakery/data/repositories/bakery_repository.dart';
import 'package:patirchi/features/bakery/menu/data/models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider({BakeryRepository? repository})
      : _repo = repository ?? BakeryRepository();

  final BakeryRepository _repo;

  // State
  bool _isLoading = false;
  String? _error;
  int? _storeId;

  List<MenuItemModel> _items = [];
  List<ProductCategory> _apiCategories = [];

  // Search/filter state
  String _searchQuery = '';
  String _selectedCategory = 'Barchasi';

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get storeId => _storeId;

  List<ProductCategory> get apiCategories => List.unmodifiable(_apiCategories);

  /// Fallback hardcoded kategoriyalar (statik — UI form init uchun).
  static const List<String> fallbackCategories = [
    'Barchasi',
    'Non',
    'Patir',
    'Somsa',
    'Shirin',
    'Boshqa',
  ];

  /// Kategoriyalar ro'yxati — API dan kelsa u, aks holda hardcoded.
  List<String> get categories {
    if (_apiCategories.isNotEmpty) {
      return ['Barchasi', ..._apiCategories.map((c) => c.name)];
    }
    return fallbackCategories;
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<MenuItemModel> get filteredItems {
    var result = _items.toList();
    if (_selectedCategory != 'Barchasi') {
      result =
          result.where((item) => item.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result =
          result.where((item) => item.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  List<MenuItemModel> get allItems => List.unmodifiable(_items);

  // ---------------------------------------------------------------------------
  // Init — storeId ni topib mahsulotlarni yuklaydi
  // ---------------------------------------------------------------------------

  /// Foydalanuvchi do'konini topib, mahsulotlarni va kategoriyalarni yuklaydi.
  ///
  /// Agar API xato qaytarsa, mock data bilan davom etiladi.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // StoreId ni aniqlaymiz
    if (_storeId == null) {
      final storesResult = await _repo.getMyStores();
      storesResult.fold(
        onSuccess: (stores) {
          if (stores.isNotEmpty) {
            _storeId = stores.first.id;
          }
        },
        onError: (failure) {
          _error = failure.toUserMessage();
        },
      );
    }

    // Kategoriyalarni yuklash (parallel)
    if (_apiCategories.isEmpty) {
      final catResult = await _repo.getCategories();
      catResult.fold(
        onSuccess: (cats) => _apiCategories = cats,
        onError: (_) {}, // xato bo'lsa hardcoded kategoriyalar ishlatiladi
      );
    }

    // Mahsulotlarni yuklash
    if (_storeId != null) {
      final productsResult = await _repo.getStoreProducts(_storeId!);
      productsResult.fold(
        onSuccess: (products) => _items = products,
        onError: (failure) {
          _error = failure.toUserMessage();
          _items = _mockItems;
        },
      );
    } else {
      // Do'kon topilmasa mock data
      _items = _mockItems;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filter/Search
  // ---------------------------------------------------------------------------

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Yangi mahsulot qo'shadi.
  ///
  /// Agar [_storeId] mavjud bo'lsa API ga yuboradi, aks holda lokalda saqlaydi.
  Future<void> addItemFromApi({
    required String name,
    required String description,
    required int price,
    required int categoryId,
    required int weight,
    required String ingredients,
  }) async {
    if (_storeId == null) return;

    _isLoading = true;
    notifyListeners();

    final data = {
      'name': name,
      'description': description,
      'price': price.toString(),
      'category': categoryId,
      'weight': weight,
      'ingredients': ingredients,
    };

    final result = await _repo.createProduct(_storeId!, data);
    result.fold(
      onSuccess: (item) => _items = [..._items, item],
      onError: (failure) => _error = failure.toUserMessage(),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lokal addItem — UI existing flow bilan mos.
  void addItem(MenuItemModel item) {
    _items = [..._items, item];
    notifyListeners();
  }

  /// Mahsulotni yangilaydi.
  Future<void> updateItemFromApi(
    int productId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repo.updateProduct(productId, data);
    result.fold(
      onSuccess: (updated) {
        _items = _items
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      },
      onError: (failure) => _error = failure.toUserMessage(),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lokal updateItem — UI existing flow bilan mos.
  void updateItem(MenuItemModel updated) {
    _items = _items
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    notifyListeners();
  }

  /// Mahsulotni o'chiradi.
  Future<void> deleteItemFromApi(int productId) async {
    final result = await _repo.deleteProduct(productId);
    result.fold(
      onSuccess: (_) {
        _items = _items
            .where((item) => item.id != productId.toString())
            .toList();
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.toUserMessage();
        notifyListeners();
      },
    );
  }

  /// Lokal deleteItem — UI existing flow bilan mos.
  void deleteItem(String id) {
    _items = _items.where((i) => i.id != id).toList();
    notifyListeners();
  }

  void toggleAvailability(String id) {
    _items = _items.map((item) {
      if (item.id != id) return item;
      return item.copyWith(isAvailable: !item.isAvailable);
    }).toList();
    notifyListeners();
  }

  MenuItemModel? getById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } on StateError {
      return null;
    }
  }

  MenuItemModel createNew({
    required String name,
    required String description,
    required int price,
    int? oldPrice,
    required String category,
    required double weight,
    required String weightUnit,
    List<String> ingredients = const [],
  }) {
    final nextId = _items.isEmpty
        ? '1'
        : ((_items
                    .map((i) => int.tryParse(i.id) ?? 0)
                    .reduce((a, b) => a > b ? a : b)) +
                1)
            .toString();
    return MenuItemModel(
      id: nextId,
      name: name,
      description: description,
      price: price,
      oldPrice: oldPrice,
      category: category,
      weight: weight,
      weightUnit: weightUnit,
      ingredients: ingredients,
      createdAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Mock fallback data
  // ---------------------------------------------------------------------------

  static final List<MenuItemModel> _mockItems = [
    MenuItemModel(
      id: '1',
      name: 'Qoqon Patir',
      description: "Qoqon uslubida pishirilgan an'anaviy patir noni",
      price: 5000,
      category: 'Patir',
      weight: 0.5,
      weightUnit: 'kg',
      ingredients: ["Un", "Yog'", 'Tuz', 'Sedana'],
      isAvailable: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    MenuItemModel(
      id: '2',
      name: 'Tandir Non',
      description: 'Tandirda pishirilgan yumshoq va mazali non',
      price: 3000,
      category: 'Non',
      weight: 0.4,
      weightUnit: 'kg',
      ingredients: ['Un', 'Suv', 'Tuz', 'Xamirturush'],
      isAvailable: true,
      createdAt: DateTime(2026, 1, 5),
    ),
    MenuItemModel(
      id: '3',
      name: "Go'sht Somsa",
      description: "Mol go'shtidan tayyorlangan qozonli somsa",
      price: 2500,
      category: 'Somsa',
      weight: 0.15,
      weightUnit: 'kg',
      ingredients: ["Go'sht", 'Piyoz', 'Un', "Yog'", 'Tuz', 'Qalampir'],
      isAvailable: true,
      createdAt: DateTime(2026, 1, 10),
    ),
    MenuItemModel(
      id: '4',
      name: 'Karam Somsa',
      description: 'Karam va piyozdan tayyorlangan yupqa somsa',
      price: 2000,
      category: 'Somsa',
      weight: 0.12,
      weightUnit: 'kg',
      ingredients: ['Karam', 'Piyoz', 'Un', "Yog'", 'Tuz'],
      isAvailable: true,
      createdAt: DateTime(2026, 1, 12),
    ),
    MenuItemModel(
      id: '5',
      name: 'Gul Non',
      description: 'Bezakli gul shaklida pishirilgan bayramlik non',
      price: 7000,
      oldPrice: 8000,
      category: 'Non',
      weight: 0.6,
      weightUnit: 'kg',
      ingredients: ['Un', 'Tuxum', 'Sut', "Yog'", 'Shakar'],
      isAvailable: true,
      createdAt: DateTime(2026, 1, 15),
    ),
    MenuItemModel(
      id: '6',
      name: 'Shakarbura',
      description: "Yong'oqli va mazali an'anaviy shakarbura",
      price: 1500,
      category: 'Shirin',
      weight: 0.08,
      weightUnit: 'kg',
      ingredients: ['Un', 'Tuxum', 'Shakar', "Yong'oq", 'Kardamon'],
      isAvailable: true,
      createdAt: DateTime(2026, 2, 1),
    ),
    MenuItemModel(
      id: '7',
      name: 'Yupqa Non',
      description: 'Ingichka va qatlamli lavash noni',
      price: 4000,
      category: 'Non',
      weight: 0.3,
      weightUnit: 'kg',
      ingredients: ['Un', 'Suv', 'Tuz', "Yog'"],
      isAvailable: false,
      createdAt: DateTime(2026, 2, 5),
    ),
    MenuItemModel(
      id: '8',
      name: 'Qatlama',
      description: "Ko'p qatlamli va yog'li qatlama",
      price: 3500,
      category: 'Boshqa',
      weight: 0.25,
      weightUnit: 'kg',
      ingredients: ['Un', 'Sut', "Yog'", 'Tuz'],
      isAvailable: true,
      createdAt: DateTime(2026, 2, 8),
    ),
  ];
}
