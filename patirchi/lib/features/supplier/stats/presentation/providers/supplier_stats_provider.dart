import 'package:flutter/foundation.dart';

enum StatsPeriod { today, week, month }

class ProductSalesStat {
  final String productName;
  final int totalSold;
  final int revenue;
  final double relativeShare;

  const ProductSalesStat({
    required this.productName,
    required this.totalSold,
    required this.revenue,
    required this.relativeShare,
  });
}

class SupplierStatsProvider extends ChangeNotifier {
  StatsPeriod _period = StatsPeriod.week;

  StatsPeriod get period => _period;

  void setPeriod(StatsPeriod p) {
    _period = p;
    notifyListeners();
  }

  int get totalRevenue {
    switch (_period) {
      case StatsPeriod.today:
        return 4_200_000;
      case StatsPeriod.week:
        return 31_500_000;
      case StatsPeriod.month:
        return 124_800_000;
    }
  }

  int get orderCount {
    switch (_period) {
      case StatsPeriod.today:
        return 3;
      case StatsPeriod.week:
        return 24;
      case StatsPeriod.month:
        return 98;
    }
  }

  int get avgOrderValue => orderCount > 0 ? totalRevenue ~/ orderCount : 0;

  int get activeCustomers {
    switch (_period) {
      case StatsPeriod.today:
        return 2;
      case StatsPeriod.week:
        return 11;
      case StatsPeriod.month:
        return 18;
    }
  }

  int get revenueChange {
    switch (_period) {
      case StatsPeriod.today:
        return 8;
      case StatsPeriod.week:
        return 14;
      case StatsPeriod.month:
        return 22;
    }
  }

  List<ProductSalesStat> get topProducts {
    switch (_period) {
      case StatsPeriod.today:
        return const [
          ProductSalesStat(
            productName: '1-nav un',
            totalSold: 300,
            revenue: 2_850_000,
            relativeShare: 1.0,
          ),
          ProductSalesStat(
            productName: 'Oliy nav un',
            totalSold: 100,
            revenue: 1_200_000,
            relativeShare: 0.42,
          ),
          ProductSalesStat(
            productName: "G'o'za yog'i",
            totalSold: 10,
            revenue: 180_000,
            relativeShare: 0.06,
          ),
        ];
      case StatsPeriod.week:
        return const [
          ProductSalesStat(
            productName: '1-nav un',
            totalSold: 2100,
            revenue: 19_950_000,
            relativeShare: 1.0,
          ),
          ProductSalesStat(
            productName: 'Oliy nav un',
            totalSold: 600,
            revenue: 7_200_000,
            relativeShare: 0.36,
          ),
          ProductSalesStat(
            productName: "G'o'za yog'i",
            totalSold: 80,
            revenue: 1_440_000,
            relativeShare: 0.072,
          ),
          ProductSalesStat(
            productName: 'Oq shakar',
            totalSold: 180,
            revenue: 2_520_000,
            relativeShare: 0.126,
          ),
          ProductSalesStat(
            productName: 'Tuxum (qishloq)',
            totalSold: 480,
            revenue: 864_000,
            relativeShare: 0.043,
          ),
        ];
      case StatsPeriod.month:
        return const [
          ProductSalesStat(
            productName: '1-nav un',
            totalSold: 8500,
            revenue: 80_750_000,
            relativeShare: 1.0,
          ),
          ProductSalesStat(
            productName: 'Oliy nav un',
            totalSold: 2400,
            revenue: 28_800_000,
            relativeShare: 0.357,
          ),
          ProductSalesStat(
            productName: 'Oq shakar',
            totalSold: 720,
            revenue: 10_080_000,
            relativeShare: 0.125,
          ),
          ProductSalesStat(
            productName: "G'o'za yog'i",
            totalSold: 310,
            revenue: 5_580_000,
            relativeShare: 0.069,
          ),
          ProductSalesStat(
            productName: 'Tuxum (qishloq)',
            totalSold: 1800,
            revenue: 3_240_000,
            relativeShare: 0.04,
          ),
        ];
    }
  }

  // Bar chart data: 7 days bars (relative heights 0..1)
  List<double> get chartBars {
    switch (_period) {
      case StatsPeriod.today:
        return [0.3, 0.5, 0.4, 0.6, 0.7, 0.4, 0.8];
      case StatsPeriod.week:
        return [0.6, 0.45, 0.7, 0.55, 0.8, 0.9, 0.65];
      case StatsPeriod.month:
        return [0.5, 0.6, 0.55, 0.7, 0.65, 0.8, 1.0];
    }
  }
}
