import 'package:flutter/material.dart';
import '../../data/datasources/buyer_home_local_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/models/shop_model.dart';

class BuyerHomeProvider extends ChangeNotifier {
  List<ProductModel> _allProducts = [];
  List<ProductModel> _visibleProducts = [];
  List<ShopModel> _shops = [];
  String _searchQuery = '';
  int _selectedCategory = 0;

  // Pagination
  static const int _pageSize = 6;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  List<ProductModel> get products => _searchQuery.isEmpty
      ? _visibleProducts
      : _allProducts
          .where(
              (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<ShopModel> get shops => _shops;
  int get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;

  BuyerHomeProvider() {
    loadData();
  }

  void loadData() {
    _allProducts = List.from(BuyerHomeLocalDatasource.products);
    _shops = List.from(BuyerHomeLocalDatasource.shops);
    _currentPage = 0;
    _hasMore = true;
    _visibleProducts = _allProducts.take(_pageSize).toList();
    _hasMore = _visibleProducts.length < _allProducts.length;
    notifyListeners();
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _allProducts = List.from(BuyerHomeLocalDatasource.products);
    _shops = List.from(BuyerHomeLocalDatasource.shops);
    _currentPage = 0;
    _visibleProducts = _allProducts.take(_pageSize).toList();
    _hasMore = _visibleProducts.length < _allProducts.length;

    _isRefreshing = false;
    notifyListeners();
  }

  /// Infinite scroll — load next page
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _searchQuery.isNotEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _currentPage++;
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    final nextBatch = _allProducts.sublist(
      start,
      end > _allProducts.length ? _allProducts.length : end,
    );
    _visibleProducts.addAll(nextBatch);
    _hasMore = _visibleProducts.length < _allProducts.length;

    _isLoadingMore = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(int index) {
    _selectedCategory = index;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    final idx = _allProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _allProducts[idx].isFavorite = !_allProducts[idx].isFavorite;
      notifyListeners();
    }
  }
}