import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({ApiClient? apiClient})
      : _repo = _OrdersRepo(apiClient ?? ApiClient.instance) {
    refresh();
  }

  final _OrdersRepo _repo;

  bool _isLoading = false;
  final List<OrderModel> _orders = [];
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<OrderModel> getActiveOrders() {
    return _orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.delivering)
        .toList();
  }

  List<OrderModel> getHistoryOrders() {
    return _orders
        .where((o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled)
        .toList();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repo.fetchOrders();

    result.fold(
      onSuccess: (fetched) {
        _orders
          ..clear()
          ..addAll(fetched);
        _error = null;
      },
      onError: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1 && _orders[idx].status == OrderStatus.pending) {
      _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
      notifyListeners();
    }
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}

/// Private repository helper — uses BaseRepository.safeApiCall.
class _OrdersRepo extends BaseRepository {
  _OrdersRepo(this._api);

  final ApiClient _api;

  Future<Result<List<OrderModel>>> fetchOrders() {
    return safeApiCall(() async {
      final response = await _api.get(ApiEndpoints.myOrders);
      final list = response['results'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
