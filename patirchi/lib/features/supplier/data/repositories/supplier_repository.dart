import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/models/store_model.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/supplier/orders/data/models/supplier_order_model.dart';
import 'package:patirchi/features/supplier/products/data/models/supplier_product_model.dart';

/// Ta'minotchi xususiyatlari uchun repository.
///
/// Barcha API so'rovlari [BaseRepository.safeApiCall] orqali xavfsiz bajariladi.
class SupplierRepository extends BaseRepository {
  SupplierRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  // ---------------------------------------------------------------------------
  // Do'konlar
  // ---------------------------------------------------------------------------

  /// Joriy foydalanuvchining supplier do'konlarini qaytaradi.
  ///
  /// `GET /site/stores/?menu=supplier`
  Future<Result<List<StoreInfo>>> getMyStores() {
    return safeApiCall(() async {
      final response = await _api.get(
        ApiEndpoints.myStores,
        queryParams: {'menu': 'supplier'},
      );
      final results = (response['results'] as List?) ??
          (response is List ? response as List : <dynamic>[]);
      return results
          .whereType<Map<String, dynamic>>()
          .map(StoreInfo.fromJson)
          .toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Mahsulotlar
  // ---------------------------------------------------------------------------

  /// Ta'minotchi mahsulotlarini qaytaradi.
  ///
  /// `GET /site/supplier-products/`
  Future<Result<List<SupplierProductModel>>> getSupplierProducts() {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.supplierProducts);
      final results = response['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(SupplierProductModel.fromApiListJson)
          .toList();
    });
  }

  /// Bitta ta'minotchi mahsulotini qaytaradi (detail).
  ///
  /// `GET /site/supplier-products/<id>/`
  Future<Result<SupplierProductModel>> getSupplierProduct(int id) {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.supplierProductDetail(id));
      return SupplierProductModel.fromApiDetailJson(response);
    });
  }

  /// Do'konga yangi ta'minotchi mahsulot qo'shadi (hozirda JSON, no images).
  ///
  /// `POST /site/stores/<storeId>/supplier-products/create/`
  ///
  /// TODO(multipart): Rasmlar qo'shilgach, postMultipart metodiga o'tish kerak.
  Future<Result<SupplierProductModel>> createProduct(
    int storeId,
    Map<String, dynamic> data,
  ) {
    return safeApiCall(() async {
      final response = await _api.post(
        ApiEndpoints.supplierProductCreate(storeId),
        body: data,
      );
      return SupplierProductModel.fromApiListJson(response);
    });
  }

  /// Ta'minotchi mahsulotini yangilaydi.
  ///
  /// `PUT /site/supplier-products/<id>/`
  Future<Result<SupplierProductModel>> updateProduct(
    int productId,
    Map<String, dynamic> data,
  ) {
    return safeApiCall(() async {
      final response = await _api.put(
        ApiEndpoints.supplierProductDetail(productId),
        body: data,
      );
      return SupplierProductModel.fromApiListJson(response);
    });
  }

  /// Ta'minotchi mahsulotini o'chiradi (soft delete).
  ///
  /// `DELETE /site/supplier-products/<id>/`
  Future<Result<bool>> deleteProduct(int productId) {
    return safeApiCall(() async {
      await _api.delete(ApiEndpoints.supplierProductDetail(productId));
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Buyurtmalar
  // ---------------------------------------------------------------------------

  /// Ta'minotchi buyurtmalarini qaytaradi, ixtiyoriy status filtri bilan.
  ///
  /// `GET /site/supplier/orders/?status=X`
  Future<Result<List<SupplierOrderModel>>> getSupplierOrders({
    String? status,
  }) {
    return safeApiCall(() async {
      final params = <String, String>{};
      if (status != null) params['status'] = status;

      final response = await _api.get(
        ApiEndpoints.supplierOrders,
        queryParams: params.isEmpty ? null : params,
      );

      final results = response['results'] as List? ?? [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(SupplierOrderModel.fromApiJson)
          .toList();
    });
  }
}
