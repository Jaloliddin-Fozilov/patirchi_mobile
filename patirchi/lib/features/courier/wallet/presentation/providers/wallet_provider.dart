import 'package:flutter/foundation.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/courier/data/repositories/courier_repository.dart';
import 'package:patirchi/features/courier/deliveries/data/models/delivery_model.dart';
import 'package:patirchi/features/courier/wallet/data/models/earning_model.dart';

enum WalletPeriod { today, week, month }

class WalletProvider extends ChangeNotifier {
  final _repository = CourierRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String? _error;
  WalletPeriod _period = WalletPeriod.week;

  DeliveryProfile? _profile;
  List<EarningModel> _earnings = [];
  EarningsSummary _summary = EarningsSummary.empty;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get error => _error;
  WalletPeriod get period => _period;

  /// Total accumulated earnings from profile.
  int get balance => _profile?.totalEarnings ?? 0;

  List<EarningModel> get allTransactions => List.unmodifiable(_earnings);

  List<EarningModel> get filteredTransactions {
    final now = DateTime.now();
    switch (_period) {
      case WalletPeriod.today:
        return _earnings
            .where(
              (e) =>
                  e.createdAt.year == now.year &&
                  e.createdAt.month == now.month &&
                  e.createdAt.day == now.day,
            )
            .toList();
      case WalletPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return _earnings.where((e) => e.createdAt.isAfter(weekAgo)).toList();
      case WalletPeriod.month:
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return _earnings.where((e) => e.createdAt.isAfter(monthAgo)).toList();
    }
  }

  int get todayEarnings => _summary.daily.total;
  int get weeklyEarnings => _summary.weekly.total;
  int get monthlyEarnings => _summary.monthly.total;

  int get currentPeriodEarnings {
    switch (_period) {
      case WalletPeriod.today:
        return todayEarnings;
      case WalletPeriod.week:
        return weeklyEarnings;
      case WalletPeriod.month:
        return monthlyEarnings;
    }
  }

  // Relative bar chart values based on filtered transactions
  List<double> get chartBars {
    if (_earnings.isEmpty) {
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }

    // Build 7 buckets depending on period
    final now = DateTime.now();
    final buckets = List<int>.filled(7, 0);

    switch (_period) {
      case WalletPeriod.today:
        // 7 buckets = 7×3h intervals of today
        for (final e in _earnings) {
          if (e.createdAt.year == now.year &&
              e.createdAt.month == now.month &&
              e.createdAt.day == now.day) {
            final bucket = (e.createdAt.hour ~/ 3).clamp(0, 6);
            buckets[bucket] += e.amount;
          }
        }
      case WalletPeriod.week:
        // 7 buckets = last 7 days
        for (final e in _earnings) {
          final daysAgo = now.difference(e.createdAt).inDays;
          if (daysAgo >= 0 && daysAgo < 7) {
            buckets[6 - daysAgo] += e.amount;
          }
        }
      case WalletPeriod.month:
        // 7 buckets = 7 weeks
        for (final e in _earnings) {
          final daysAgo = now.difference(e.createdAt).inDays;
          if (daysAgo >= 0 && daysAgo < 28) {
            final bucket = (daysAgo ~/ 4).clamp(0, 6);
            buckets[6 - bucket] += e.amount;
          }
        }
    }

    final maxVal =
        buckets.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxVal == 0) return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    return buckets.map((v) => v / maxVal).toList();
  }

  // ---------------------------------------------------------------------------
  // Methods
  // ---------------------------------------------------------------------------

  void setPeriod(WalletPeriod p) {
    _period = p;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadProfile(),
      _loadEarnings(),
      _loadSummary(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => init();

  // ---------------------------------------------------------------------------
  // Private loaders
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    final result = await _repository.getProfile();
    result.fold(
      onSuccess: (profile) => _profile = profile,
      onError: (_) {/* ignore — balance shows 0 */},
    );
  }

  Future<void> _loadEarnings() async {
    final result = await _repository.getEarnings();
    result.fold(
      onSuccess: (earnings) => _earnings = earnings,
      onError: (failure) => _error = failure.toUserMessage(),
    );
  }

  Future<void> _loadSummary() async {
    final result = await _repository.getEarningsSummary();
    result.fold(
      onSuccess: (summary) => _summary = summary,
      onError: (_) => _summary = EarningsSummary.empty,
    );
  }
}
