import 'package:flutter/material.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/buyer/home/data/datasources/buyer_home_local_datasource.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';
import 'package:patirchi/features/buyer/home/data/models/shop_model.dart';
import 'package:patirchi/features/buyer/home/data/repositories/buyer_repository.dart';

class BuyerHomeProvider extends ChangeNotifier {
  BuyerHomeProvider({BuyerRepository? repository})
      : _repository = repository ?? BuyerRepository() {
    loadData();
  }

  final BuyerRepository _repository;

  static const int _pageSize = 20;

  List<ProductModel> _products = [];
  List<ShopModel> _shops = [];
  List<ProductCategory> _categories = [];
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  int? _selectedCategoryId;

  // Pagination state
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _isInitialLoading = true;
  String? _error;

  // Getters
  List<ProductModel> get products {
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      return _products
          .where((p) => p.name.toLowerCase().contains(lower))
          .toList();
    }
    return _products;
  }

  List<ShopModel> get shops => _shops;
  List<ProductCategory> get categories => _categories;
  int get selectedCategory => _selectedCategoryIndex;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // Initial load
  // ---------------------------------------------------------------------------

  Future<void> loadData() async {
    _isInitialLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadProducts(reset: true),
      _loadShops(),
      _loadCategories(),
    ]);

    _isInitialLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }

    final result = await _repository.getProducts(
      limit: _pageSize,
      offset: _offset,
      category: _selectedCategoryId,
    );

    result.fold(
      onSuccess: (items) {
        if (reset) {
          _products = items;
        } else {
          _products = [..._products, ...items];
        }
        _hasMore = items.length >= _pageSize;
        _offset = _products.length;
        _error = null;
      },
      onError: (failure) {
        if (reset) {
          // Fallback to local data on initial load failure
          _products = List.from(BuyerHomeLocalDatasource.products);
          _hasMore = false;
        }
        _error = failure.message;
      },
    );
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();

    await Future.wait([
      _loadProducts(reset: true),
      _loadShops(),
    ]);

    _isRefreshing = false;
    notifyListeners();
  }

  /// Infinite scroll — load next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _searchQuery.isNotEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    await _loadProducts(reset: false);

    _isLoadingMore = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Shops
  // ---------------------------------------------------------------------------

  Future<void> _loadShops() async {
    final result = await _repository.getStores();
    result.fold(
      onSuccess: (shops) {
        _shops = shops;
      },
      onError: (_) {
        if (_shops.isEmpty) {
          _shops = List.from(BuyerHomeLocalDatasource.shops);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<void> _loadCategories() async {
    final result = await _repository.getCategories();
    result.fold(
      onSuccess: (cats) => _categories = cats,
      onError: (_) {},
    );
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Category filter
  // ---------------------------------------------------------------------------

  void selectCategory(int index, {int? categoryId}) {
    _selectedCategoryIndex = index;
    _selectedCategoryId = categoryId;
    _loadProducts(reset: true).then((_) => notifyListeners());
  }

  // ---------------------------------------------------------------------------
  // Favorites (local-only toggle)
  // ---------------------------------------------------------------------------

  void toggleFavorite(int productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx].isFavorite = !_products[idx].isFavorite;
      notifyListeners();
    }
  }
}
