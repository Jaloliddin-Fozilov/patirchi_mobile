import 'package:flutter/foundation.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/supplier/data/repositories/supplier_repository.dart';
import 'package:patirchi/features/supplier/products/data/models/supplier_product_model.dart';

class SupplierProductsProvider extends ChangeNotifier {
  SupplierProductsProvider({SupplierRepository? repository})
      : _repo = repository ?? SupplierRepository();

  final SupplierRepository _repo;

  // State
  bool _isLoading = false;
  String? _error;
  int? _storeId;

  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  List<SupplierProductModel> _products = [];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get storeId => _storeId;

  String get searchQuery => _searchQuery;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  static const List<String> categories = [
    'Barchasi',
    'Un',
    "Yog'",
    'Shakar',
    'Tuxum',
    'Sut',
    'Boshqa',
  ];

  List<SupplierProductModel> get filteredProducts {
    var result = List<SupplierProductModel>.from(_products);

    if (_selectedCategoryIndex > 0) {
      final cat = categories[_selectedCategoryIndex];
      result = result.where((p) => p.category?.name == cat).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.category?.name.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return result;
  }

  List<SupplierProductModel> get allProducts => List.unmodifiable(_products);

  // ---------------------------------------------------------------------------
  // Init — storeId ni topib mahsulotlarni yuklaydi
  // ---------------------------------------------------------------------------

  /// Foydalanuvchi do'konini topib, mahsulotlarni yuklaydi.
  ///
  /// Agar API xato qaytarsa, mock data bilan davom etiladi.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // StoreId ni aniqlaymiz (keyinchalik create uchun kerak bo'ladi)
    if (_storeId == null) {
      final storesResult = await _repo.getMyStores();
      storesResult.fold(
        onSuccess: (stores) {
          if (stores.isNotEmpty) {
            _storeId = stores.first.id;
          }
        },
        onError: (_) {}, // xato bo'lsa davom etamiz
      );
    }

    // Mahsulotlarni yuklash
    final result = await _repo.getSupplierProducts();
    result.fold(
      onSuccess: (products) => _products = products,
      onError: (failure) {
        _error = failure.toUserMessage();
        _products = _mockProducts;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filter/Search
  // ---------------------------------------------------------------------------

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// API orqali yangi mahsulot qo'shadi.
  Future<void> addProductFromApi({
    required String name,
    required String? description,
    required int price,
    required String units,
    required int? weight,
    required String? ingredients,
  }) async {
    if (_storeId == null) return;

    _isLoading = true;
    notifyListeners();

    final data = {
      'name': name,
      if (description != null) 'description': description,
      'price': price.toString(),
      'units': units,
      if (weight != null) 'weight': weight,
      if (ingredients != null) 'ingredients': ingredients,
    };

    final result = await _repo.createProduct(_storeId!, data);
    result.fold(
      onSuccess: (product) => _products = <SupplierProductModel>[..._products, product],
      onError: (failure) => _error = failure.toUserMessage(),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lokal addProduct — UI existing flow bilan mos.
  void addProduct(SupplierProductModel product) {
    _products = [..._products, product];
    notifyListeners();
  }

  /// API orqali mahsulotni yangilaydi.
  Future<void> updateProductFromApi(
    int productId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repo.updateProduct(productId, data);
    result.fold(
      onSuccess: (updated) {
        _products = _products
            .map<SupplierProductModel>((p) => p.id == updated.id ? updated : p)
            .toList();
      },
      onError: (failure) => _error = failure.toUserMessage(),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lokal updateProduct — UI existing flow bilan mos.
  void updateProduct(SupplierProductModel updated) {
    _products = _products
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
    notifyListeners();
  }

  /// API orqali mahsulotni o'chiradi.
  Future<void> deleteProductFromApi(int productId) async {
    final result = await _repo.deleteProduct(productId);
    result.fold(
      onSuccess: (_) {
        _products = _products.where((p) => p.id != productId).toList();
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.toUserMessage();
        notifyListeners();
      },
    );
  }

  /// Lokal deleteProduct — UI existing flow bilan mos.
  void deleteProduct(int id) {
    _products = _products.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void toggleActive(int id) {
    _products = _products.map((p) {
      if (p.id != id) return p;
      return p.copyWith(isAvailable: !p.isAvailable, isActive: !p.isActive);
    }).toList();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mock fallback data
  // ---------------------------------------------------------------------------

  static final List<SupplierProductModel> _mockProducts = [
    SupplierProductModel(
      id: 1,
      name: 'Oliy nav un',
      description: "Toshkent tegirmonidan eng sifatli oliy nav bug'doy uni",
      price: 12000,
      units: 'kilogram',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 2,
      name: '1-nav un',
      description: 'Standart non va pishiriqlar uchun 1-nav un',
      price: 9500,
      units: 'kilogram',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 3,
      name: "G'o'za yog'i",
      description: "Tozalangan g'o'za o'simlik moyi, pishirish uchun",
      price: 18000,
      units: 'liter',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 4,
      name: "Kungaboqar yog'i",
      description: "Rafinerlanmagan kungaboqar yog'i",
      price: 16500,
      units: 'liter',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 5,
      name: 'Oq shakar',
      description: 'Toshkent shakar zavodi standart oq shakar',
      price: 14000,
      units: 'kilogram',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 6,
      name: 'Tuxum (qishloq)',
      description: "Qishloq xo'jaligi erkin boqilgan tovuq tuxumi",
      price: 1800,
      units: 'piece',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 7,
      name: 'Sigir suti',
      description: "Yangi to'liq yog'li sigir suti",
      price: 8000,
      units: 'liter',
      isAvailable: true,
      isActive: true,
    ),
    SupplierProductModel(
      id: 8,
      name: 'Osh tuzi',
      description: "Yod qo'shilgan standart osh tuzi",
      price: 2500,
      units: 'kilogram',
      isAvailable: true,
      isActive: true,
    ),
  ];
}
