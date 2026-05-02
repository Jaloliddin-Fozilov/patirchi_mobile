import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/models/product_category_model.dart';
import 'package:patirchi/core/models/store_model.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/bakery/menu/data/models/menu_item_model.dart';
import 'package:patirchi/features/bakery/orders/presentation/providers/bakery_orders_provider.dart';

/// Bakery xususiyatlari uchun repository.
///
/// Barcha API so'rovlari [BaseRepository.safeApiCall] orqali xavfsiz bajariladi.
class BakeryRepository extends BaseRepository {
  BakeryRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  // ---------------------------------------------------------------------------
  // Do'konlar
  // ---------------------------------------------------------------------------

  /// Joriy foydalanuvchining bakery do'konlarini qaytaradi.
  ///
  /// `GET /site/stores/?menu=bakery`
  Future<Result<List<StoreInfo>>> getMyStores() {
    return safeApiCall(() async {
      final response = await _api.get(
        ApiEndpoints.myStores,
        queryParams: {'menu': 'bakery'},
      );
      final results = (response['results'] as List?) ??
          (response is List ? response as List : <dynamic>[response]);
      return results
          .whereType<Map<String, dynamic>>()
          .map(StoreInfo.fromJson)
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Buyurtmalar
  // ---------------------------------------------------------------------------

  /// Do'kon buyurtmalarini qaytaradi, ixtiyoriy status filtri bilan.
  ///
  /// `GET /site/store/orders/?status=pending`
  Future<Result<List<BakeryOrder>>> getStoreOrders({String? status}) {
    return safeApiCall(() async {
      final params = <String, String>{};
      if (status != null) params['status'] = status;

      final response = await _api.get(
        ApiEndpoints.storeOrders,
        queryParams: params.isEmpty ? null : params,
      );

      final results = response['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(BakeryOrder.fromApiJson)
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Mahsulotlar (Menu)
  // ---------------------------------------------------------------------------

  /// Do'kon mahsulotlarini qaytaradi.
  ///
  /// `GET /site/products/?store_id=X`
  Future<Result<List<MenuItemModel>>> getStoreProducts(int storeId) {
    return safeApiCall(() async {
      final response = await _api.get(
        ApiEndpoints.products,
        queryParams: {'store_id': storeId.toString()},
      );
      final results = response['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(MenuItemModel.fromApiJson)
          .toList();
    });
  }

  /// Do'konga yangi mahsulot qo'shadi (hozirda faqat JSON fields, no images).
  ///
  /// `POST /site/stores/<storeId>/products/create/`
  ///
  /// TODO(multipart): Rasmlar qo'shilgach, postMultipart metodiga o'tish kerak.
  Future<Result<MenuItemModel>> createProduct(
    int storeId,
    Map<String, dynamic> data,
  ) {
    return safeApiCall(() async {
      final response = await _api.post(
        ApiEndpoints.productCreate(storeId),
        body: data,
      );
      return MenuItemModel.fromApiJson(response);
    });
  }

  /// Mavjud mahsulotni yangilaydi.
  ///
  /// `PUT /site/products/<id>/`
  Future<Result<MenuItemModel>> updateProduct(
    int productId,
    Map<String, dynamic> data,
  ) {
    return safeApiCall(() async {
      final response = await _api.put(
        ApiEndpoints.productDetail(productId),
        body: data,
      );
      return MenuItemModel.fromApiJson(response);
    });
  }

  /// Mahsulotni o'chiradi (soft delete).
  ///
  /// `DELETE /site/products/<id>/`
  Future<Result<bool>> deleteProduct(int productId) {
    return safeApiCall(() async {
      await _api.delete(ApiEndpoints.productDetail(productId));
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Kategoriyalar
  // ---------------------------------------------------------------------------

  /// Barcha kategoriyalarni qaytaradi.
  ///
  /// `GET /site/categories/`
  Future<Result<List<ProductCategory>>> getCategories() {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.categories);
      final results = (response['results'] as List?) ??
          (response is List ? response as List : <dynamic>[]);
      return results
          .whereType<Map<String, dynamic>>()
          .map(ProductCategory.fromJson)
          .toList();
    });
  }
}
