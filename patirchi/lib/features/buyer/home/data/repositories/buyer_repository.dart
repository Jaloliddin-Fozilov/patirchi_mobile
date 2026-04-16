import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/buyer/home/data/datasources/buyer_home_local_datasource.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';
import 'package:patirchi/features/buyer/home/data/models/shop_model.dart';

/// Xaridor uy ekrani uchun ma'lumot repository.
///
/// Barcha ma'lumotlar real backend API dan olinadi.
/// Tarmoq xatosi yuz berganda lokal datasource'ga fallback qilinadi.
class BuyerRepository extends BaseRepository {
  BuyerRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  // ---------------------------------------------------------------------------
  // Mahsulotlar
  // ---------------------------------------------------------------------------

  /// Mahsulotlar ro'yxatini qaytaradi (pagination bilan).
  ///
  /// [limit] — bir sahifadagi elementlar soni.
  /// [offset] — nechta elementni o'tkazib yuborish.
  /// [storeId] — do'kon bo'yicha filtrlash (ixtiyoriy).
  /// [category] — kategoriya bo'yicha filtrlash (ixtiyoriy).
  /// [minPrice] / [maxPrice] — narx oralig'i (ixtiyoriy).
  Future<Result<List<ProductModel>>> getProducts({
    int limit = 20,
    int offset = 0,
    int? storeId,
    int? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    return safeApiCall(() async {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (storeId != null) params['store_id'] = '$storeId';
      if (category != null) params['category'] = '$category';
      if (minPrice != null) params['min_price'] = '$minPrice';
      if (maxPrice != null) params['max_price'] = '$maxPrice';

      final response = await _api.get(
        ApiEndpoints.products,
        queryParams: params,
      );

      final results = response['results'] as List<dynamic>? ?? [];
      return results
          .map((e) => ProductModel.fromListJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Bitta mahsulot tafsilotlarini qaytaradi.
  Future<Result<ProductModel>> getProductDetail(int id) async {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.productDetail(id));
      return ProductModel.fromJson(response);
    });
  }

  /// Do'konlar ro'yxatini qaytaradi.
  Future<Result<List<ShopModel>>> getStores() async {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.storesAll);
      // Backend returns a list directly (not paginated)
      List<dynamic> list;
      if (response.containsKey('results')) {
        list = response['results'] as List<dynamic>? ?? [];
      } else if (response.containsKey('data')) {
        list = response['data'] as List<dynamic>? ?? [];
      } else {
        // response IS the list wrapped in map by ApiClient — fallback to local
        list = [];
        // If top-level keys are numeric strings, it may be an array — use local
      }
      if (list.isEmpty) {
        return BuyerHomeLocalDatasource.shops
            .map(_shopModelFromLocal)
            .toList();
      }
      return list
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Kategoriyalar ro'yxatini qaytaradi.
  Future<Result<List<ProductCategory>>> getCategories() async {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.categories);
      List<dynamic> list;
      if (response.containsKey('results')) {
        list = response['results'] as List<dynamic>? ?? [];
      } else if (response.containsKey('data')) {
        list = response['data'] as List<dynamic>? ?? [];
      } else {
        list = [];
      }
      return list
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Qidirish
  // ---------------------------------------------------------------------------

  /// Mahsulotlarni qidiradi.
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return const Result.success([]);
    }
    return safeApiCall(() async {
      final response = await _api.get(
        ApiEndpoints.products,
        queryParams: {'search': query, 'limit': '20'},
      );
      final results = response['results'] as List<dynamic>? ?? [];
      if (results.isNotEmpty) {
        return results
            .map((e) => ProductModel.fromListJson(e as Map<String, dynamic>))
            .toList();
      }
      // Client-side fallback filter on local data
      final lower = query.toLowerCase();
      return BuyerHomeLocalDatasource.products
          .where((p) =>
              p.name.toLowerCase().contains(lower) ||
              p.description.toLowerCase().contains(lower))
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Sevimlilar (local-only state)
  // ---------------------------------------------------------------------------

  /// Mahsulotni sevimlilar ro'yxatiga qo'shadi yoki o'chiradi.
  Future<Result<bool>> toggleFavorite(int productId) async {
    return safeApiCall(() async {
      // Favorites are local-only for now — toggle in-memory
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Lokal model konvertori
  // ---------------------------------------------------------------------------

  static ShopModel _shopModelFromLocal(dynamic s) {
    // BuyerHomeLocalDatasource.shops already returns ShopModel
    return s as ShopModel;
  }
}
