import 'package:flutter/material.dart';
import '../../data/datasources/buyer_home_local_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/models/shop_model.dart';

class BuyerHomeProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ShopModel> _shops = [];
  String _searchQuery = '';
  int _selectedCategory = 0;

  List<ProductModel> get products => _searchQuery.isEmpty
      ? _products
      : _products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<ShopModel> get shops => _shops;
  int get selectedCategory => _selectedCategory;

  BuyerHomeProvider() {
    loadData();
  }

  void loadData() {
    _products = List.from(BuyerHomeLocalDatasource.products);
    _shops = List.from(BuyerHomeLocalDatasource.shops);
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
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx].isFavorite = !_products[idx].isFavorite;
      notifyListeners();
    }
  }
}
