import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/buyer/cart/data/models/cart_item_model.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';

/// Savatcha repository — real backend API ile savatni boshqaradi.
class CartRepository extends BaseRepository {
  CartRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  // ---------------------------------------------------------------------------
  // Savatcha o'qish
  // ---------------------------------------------------------------------------

  /// Savatchani API dan oladi.
  Future<Result<CartModel>> getCart() async {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.cart);
      return CartModel.fromJson(response);
    });
  }

  // ---------------------------------------------------------------------------
  // Savatchaga qo'shish
  // ---------------------------------------------------------------------------

  /// Mahsulotni savatchaga qo'shadi.
  ///
  /// [productId] — mahsulot ID (int).
  /// [quantity] — miqdor.
  Future<Result<String>> addToCart(int productId, int quantity) async {
    return safeApiCall(() async {
      final response = await _api.post(
        ApiEndpoints.cartAdd,
        body: {'product_id': productId, 'quantity': quantity},
      );
      return response['detail'] as String? ?? 'Savatga saqlandi.';
    });
  }

  // ---------------------------------------------------------------------------
  // Miqdorni yangilash
  // ---------------------------------------------------------------------------

  /// Savatcha elementining miqdorini yangilaydi.
  ///
  /// [cartItemId] — savatcha element ID (serverdan kelgan id).
  /// [quantity] — yangi miqdor.
  Future<Result<String>> updateQuantity(int cartItemId, int quantity) async {
    return safeApiCall(() async {
      final response = await _api.put(
        ApiEndpoints.cartUpdate(cartItemId),
        body: {'quantity': quantity},
      );
      return response['detail'] as String? ?? "Soni o'zgartirildi.";
    });
  }

  // ---------------------------------------------------------------------------
  // O'chirish
  // ---------------------------------------------------------------------------

  /// Savatcha elementini o'chiradi.
  ///
  /// [cartItemId] — savatcha element ID (serverdan kelgan id).
  Future<Result<void>> removeFromCart(int cartItemId) async {
    return safeApiCall(() async {
      await _api.delete(ApiEndpoints.cartRemove(cartItemId));
    });
  }

  // ---------------------------------------------------------------------------
  // Buyurtma berish
  // ---------------------------------------------------------------------------

  /// Aktiv savatchadan buyurtma yaratadi.
  ///
  /// Backend aktiv savatchani o'zi o'qiydi — body shart emas.
  Future<Result<OrderModel>> checkout() async {
    return safeApiCall(() async {
      final response = await _api.post(ApiEndpoints.orderCreate);
      return OrderModel.fromJson(response);
    });
  }
}
