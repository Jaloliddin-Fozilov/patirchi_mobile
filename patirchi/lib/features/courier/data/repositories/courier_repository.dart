import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/courier/deliveries/data/models/delivery_model.dart';
import 'package:patirchi/features/courier/wallet/data/models/earning_model.dart';

class CourierRepository extends BaseRepository {
  final _api = ApiClient.instance;

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<Result<DeliveryProfile>> getProfile() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryProfile);
      return DeliveryProfile.fromJson(data);
    });
  }

  Future<Result<DeliveryProfile>> updateProfile(
    Map<String, dynamic> updates,
  ) {
    return safeApiCall(() async {
      final data = await _api.patch(
        ApiEndpoints.deliveryProfile,
        body: updates,
      );
      return DeliveryProfile.fromJson(data);
    });
  }

  // ---------------------------------------------------------------------------
  // Online / Offline toggle
  // ---------------------------------------------------------------------------

  /// Flips the courier's is_available flag.
  /// Returns the new [bool] value of is_available.
  Future<Result<bool>> toggleOnlineStatus() {
    return safeApiCall(() async {
      final data = await _api.post(ApiEndpoints.deliveryToggle);
      return data['is_available'] as bool? ?? false;
    });
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  Future<Result<List<DeliveryOrderModel>>> getAvailableOrders() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryAvailable);
      final list = data['results'] as List<dynamic>? ?? data as List<dynamic>;
      return list
          .map(
            (e) => DeliveryOrderModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<Result<List<DeliveryOrderModel>>> getActiveOrders() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryActive);
      final list = data['results'] as List<dynamic>? ?? data as List<dynamic>;
      return list
          .map(
            (e) => DeliveryOrderModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<Result<List<DeliveryOrderModel>>> getOrderHistory() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryHistory);
      final list = data['results'] as List<dynamic>? ?? data as List<dynamic>;
      return list
          .map(
            (e) => DeliveryOrderModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<Result<DeliveryOrderModel>> getOrderDetail(int id) {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryDetail(id));
      return DeliveryOrderModel.fromJson(data);
    });
  }

  // ---------------------------------------------------------------------------
  // Order actions (state machine)
  // ---------------------------------------------------------------------------

  Future<Result<DeliveryOrderModel>> acceptOrder(int id) {
    return safeApiCall(() async {
      final data = await _api.post(ApiEndpoints.deliveryAction(id, 'accept'));
      return DeliveryOrderModel.fromJson(data);
    });
  }

  Future<Result<DeliveryOrderModel>> pickupOrder(int id) {
    return safeApiCall(() async {
      final data = await _api.post(ApiEndpoints.deliveryAction(id, 'pickup'));
      return DeliveryOrderModel.fromJson(data);
    });
  }

  Future<Result<DeliveryOrderModel>> deliverOrder(int id) {
    return safeApiCall(() async {
      final data = await _api.post(ApiEndpoints.deliveryAction(id, 'deliver'));
      return DeliveryOrderModel.fromJson(data);
    });
  }

  Future<Result<DeliveryOrderModel>> cancelOrder(int id) {
    return safeApiCall(() async {
      final data = await _api.post(ApiEndpoints.deliveryAction(id, 'cancel'));
      return DeliveryOrderModel.fromJson(data);
    });
  }

  // ---------------------------------------------------------------------------
  // Earnings
  // ---------------------------------------------------------------------------

  Future<Result<List<EarningModel>>> getEarnings() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryEarnings);
      final list = data['results'] as List<dynamic>? ?? data as List<dynamic>;
      return list
          .map((e) => EarningModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Result<EarningsSummary>> getEarningsSummary() {
    return safeApiCall(() async {
      final data = await _api.get(ApiEndpoints.deliveryEarningsSummary);
      return EarningsSummary.fromJson(data);
    });
  }

  // ---------------------------------------------------------------------------
  // Ratings
  // ---------------------------------------------------------------------------

  Future<Result<List<Map<String, dynamic>>>> getRatings() {
    return safeApiCall(() async {
      final data = await _api.get('/site/delivery/ratings/');
      final list = data['results'] as List<dynamic>? ?? data as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    });
  }
}
