import 'package:flutter/foundation.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/courier/data/repositories/courier_repository.dart';
import 'package:patirchi/features/courier/deliveries/data/models/delivery_model.dart';

class CourierProvider extends ChangeNotifier {
  final _repository = CourierRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String? _error;
  DeliveryProfile? _profile;

  List<DeliveryOrderModel> _availableOrders = [];
  List<DeliveryOrderModel> _activeOrders = [];
  List<DeliveryOrderModel> _historyOrders = [];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get error => _error;
  DeliveryProfile? get profile => _profile;

  bool get isOnline => _profile?.isAvailable ?? false;

  List<DeliveryOrderModel> get availableDeliveries =>
      List.unmodifiable(_availableOrders);
  List<DeliveryOrderModel> get myActiveDeliveries =>
      List.unmodifiable(_activeOrders);
  List<DeliveryOrderModel> get completedDeliveries =>
      List.unmodifiable(_historyOrders);

  int get todayEarnings {
    final today = DateTime.now();
    return _historyOrders
        .where(
          (d) =>
              d.isDelivered &&
              d.deliveredAt != null &&
              d.deliveredAt!.year == today.year &&
              d.deliveredAt!.month == today.month &&
              d.deliveredAt!.day == today.day,
        )
        .fold(0, (sum, d) => sum + d.deliveryFee);
  }

  int get todayDeliveryCount {
    final today = DateTime.now();
    return _historyOrders
        .where(
          (d) =>
              d.isDelivered &&
              d.deliveredAt != null &&
              d.deliveredAt!.year == today.year &&
              d.deliveredAt!.month == today.month &&
              d.deliveredAt!.day == today.day,
        )
        .length;
  }

  // ---------------------------------------------------------------------------
  // Initialisation — called once from CourierShell
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadProfile(),
      _loadAvailableOrders(),
      _loadActiveOrders(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    final result = await _repository.getProfile();
    result.fold(
      onSuccess: (profile) => _profile = profile,
      onError: (failure) {
        // 404 means profile not yet created — leave _profile null
        if (failure.code != 404) {
          _error = failure.toUserMessage();
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Toggle online / offline
  // ---------------------------------------------------------------------------

  Future<void> toggleOnline() async {
    // Optimistic update
    final previous = _profile;
    if (_profile != null) {
      _profile = _profile!.copyWith(isAvailable: !_profile!.isAvailable);
      notifyListeners();
    }

    final result = await _repository.toggleOnlineStatus();
    result.fold(
      onSuccess: (isAvailable) {
        if (_profile != null) {
          _profile = _profile!.copyWith(isAvailable: isAvailable);
        }
      },
      onError: (_) {
        // Roll back
        _profile = previous;
      },
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Orders — loading
  // ---------------------------------------------------------------------------

  Future<void> _loadAvailableOrders() async {
    final result = await _repository.getAvailableOrders();
    result.fold(
      onSuccess: (orders) => _availableOrders = orders,
      onError: (_) => _availableOrders = _availableOrders,
    );
  }

  Future<void> _loadActiveOrders() async {
    final result = await _repository.getActiveOrders();
    result.fold(
      onSuccess: (orders) => _activeOrders = orders,
      onError: (_) => _activeOrders = _activeOrders,
    );
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _loadAvailableOrders(),
      _loadActiveOrders(),
    ]);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Order actions
  // ---------------------------------------------------------------------------

  Future<bool> acceptDelivery(int id) async {
    // Optimistic: move from available → active list
    final idx = _availableOrders.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final updated = _availableOrders[idx].copyWith(status: 'accepted');
      _availableOrders = List.of(_availableOrders)..removeAt(idx);
      _activeOrders = [updated, ..._activeOrders];
      notifyListeners();
    }

    final result = await _repository.acceptOrder(id);
    return result.fold(
      onSuccess: (updated) {
        _syncActiveOrder(updated);
        notifyListeners();
        return true;
      },
      onError: (_) {
        // Roll back: reload
        _loadAvailableOrders().then((_) => _loadActiveOrders()).then((_) {
          notifyListeners();
        });
        return false;
      },
    );
  }

  Future<bool> pickUp(int id) async {
    _updateActiveOrderStatus(id, 'picked_up');

    final result = await _repository.pickupOrder(id);
    return result.fold(
      onSuccess: (updated) {
        _syncActiveOrder(updated);
        notifyListeners();
        return true;
      },
      onError: (_) {
        _loadActiveOrders().then((_) => notifyListeners());
        return false;
      },
    );
  }

  Future<bool> markDelivered(int id) async {
    // Optimistic: move from active → history
    final idx = _activeOrders.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final updated = _activeOrders[idx].copyWith(
        status: 'delivered',
        deliveredAt: DateTime.now(),
      );
      _activeOrders = List.of(_activeOrders)..removeAt(idx);
      _historyOrders = [updated, ..._historyOrders];
      notifyListeners();
    }

    final result = await _repository.deliverOrder(id);
    return result.fold(
      onSuccess: (updated) {
        _syncHistoryOrder(updated);
        notifyListeners();
        return true;
      },
      onError: (_) {
        _loadActiveOrders().then((_) => notifyListeners());
        return false;
      },
    );
  }

  DeliveryOrderModel? findById(int id) {
    try {
      return [
        ..._availableOrders,
        ..._activeOrders,
        ..._historyOrders,
      ].firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private sync helpers
  // ---------------------------------------------------------------------------

  void _updateActiveOrderStatus(int id, String newStatus) {
    final idx = _activeOrders.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final orders = List.of(_activeOrders);
      orders[idx] = orders[idx].copyWith(status: newStatus);
      _activeOrders = orders;
      notifyListeners();
    }
  }

  void _syncActiveOrder(DeliveryOrderModel updated) {
    final idx = _activeOrders.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      final orders = List.of(_activeOrders);
      orders[idx] = updated;
      _activeOrders = orders;
    }
  }

  void _syncHistoryOrder(DeliveryOrderModel updated) {
    final idx = _historyOrders.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      final orders = List.of(_historyOrders);
      orders[idx] = updated;
      _historyOrders = orders;
    }
  }
}
