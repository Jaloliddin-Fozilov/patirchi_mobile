import 'package:flutter/foundation.dart';
import '../../data/models/transaction_model.dart';

enum FinancePeriod { today, week, month, year }

class DailyFinanceData {
  final String label;
  final int income;
  final int expense;

  const DailyFinanceData({
    required this.label,
    required this.income,
    required this.expense,
  });

  int get profit => income - expense;
}

class FinanceProvider extends ChangeNotifier {
  FinancePeriod _period = FinancePeriod.month;

  FinancePeriod get period => _period;

  final List<TransactionModel> _allTransactions = [
    TransactionModel(
      id: '1',
      description: 'Buyurtma #1005',
      amount: 65000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 15, 16, 45),
    ),
    TransactionModel(
      id: '2',
      description: 'Un xarid',
      amount: 120000,
      type: TransactionType.expense,
      category: "Xomashyo",
      date: DateTime(2026, 4, 14, 10, 0),
    ),
    TransactionModel(
      id: '3',
      description: 'Buyurtma #1004',
      amount: 40000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 15, 14, 20),
    ),
    TransactionModel(
      id: '4',
      description: "Maosh to'lovi",
      amount: 800000,
      type: TransactionType.expense,
      category: 'Maosh',
      date: DateTime(2026, 4, 1, 9, 0),
    ),
    TransactionModel(
      id: '5',
      description: 'Buyurtma #1003',
      amount: 22000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 16, 11, 0),
    ),
    TransactionModel(
      id: '6',
      description: "Yog' xarid",
      amount: 75000,
      type: TransactionType.expense,
      category: 'Xomashyo',
      date: DateTime(2026, 4, 13, 11, 30),
    ),
    TransactionModel(
      id: '7',
      description: 'Buyurtma #1002',
      amount: 20000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 16, 10, 30),
    ),
    TransactionModel(
      id: '8',
      description: 'Kommunal xarajatlar',
      amount: 150000,
      type: TransactionType.expense,
      category: 'Kommunal',
      date: DateTime(2026, 4, 5, 8, 0),
    ),
    TransactionModel(
      id: '9',
      description: 'Tovar sotuvi (ulgurji)',
      amount: 500000,
      type: TransactionType.income,
      category: "Ulgurji savdo",
      date: DateTime(2026, 4, 10, 14, 0),
    ),
    TransactionModel(
      id: '10',
      description: 'Tandirni ta\'mirlash',
      amount: 90000,
      type: TransactionType.expense,
      category: "Ta'mirlash",
      date: DateTime(2026, 4, 8, 10, 0),
    ),
    TransactionModel(
      id: '11',
      description: 'Buyurtma #1001',
      amount: 31000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 16, 9, 15),
    ),
    TransactionModel(
      id: '12',
      description: 'Shakar xarid',
      amount: 45000,
      type: TransactionType.expense,
      category: 'Xomashyo',
      date: DateTime(2026, 4, 12, 9, 0),
    ),
    TransactionModel(
      id: '13',
      description: 'Buyurtma (mart oxiri)',
      amount: 320000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 3, 28, 15, 0),
    ),
    TransactionModel(
      id: '14',
      description: 'Reklama xarajatlari',
      amount: 50000,
      type: TransactionType.expense,
      category: 'Marketing',
      date: DateTime(2026, 4, 7, 11, 0),
    ),
    TransactionModel(
      id: '15',
      description: 'Buyurtma (april boshi)',
      amount: 180000,
      type: TransactionType.income,
      category: 'Buyurtma',
      date: DateTime(2026, 4, 2, 10, 0),
    ),
  ];

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return _allTransactions.where((t) {
      switch (_period) {
        case FinancePeriod.today:
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        case FinancePeriod.week:
          return t.date.isAfter(now.subtract(const Duration(days: 7)));
        case FinancePeriod.month:
          return t.date.year == now.year && t.date.month == now.month;
        case FinancePeriod.year:
          return t.date.year == now.year;
      }
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int get totalIncome => filteredTransactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpense => filteredTransactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get profit => totalIncome - totalExpense;

  List<DailyFinanceData> get chartData {
    // Return last 7 days for all periods except year
    if (_period == FinancePeriod.year) {
      return _getMonthlyData();
    }
    return _getDailyData();
  }

  List<DailyFinanceData> _getDailyData() {
    final days = <DailyFinanceData>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayTx = _allTransactions.where((t) =>
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day);
      final inc = dayTx
          .where((t) => t.isIncome)
          .fold(0, (s, t) => s + t.amount);
      final exp = dayTx
          .where((t) => !t.isIncome)
          .fold(0, (s, t) => s + t.amount);
      days.add(DailyFinanceData(
        label: '${day.day}/${day.month}',
        income: inc,
        expense: exp,
      ));
    }
    return days;
  }

  List<DailyFinanceData> _getMonthlyData() {
    final months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn', 'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    final data = <DailyFinanceData>[];
    final now = DateTime.now();
    for (var m = 1; m <= now.month; m++) {
      final monthTx = _allTransactions.where((t) =>
          t.date.year == now.year && t.date.month == m);
      final inc =
          monthTx.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
      final exp =
          monthTx.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);
      data.add(DailyFinanceData(
        label: months[m - 1],
        income: inc,
        expense: exp,
      ));
    }
    return data;
  }

  void setPeriod(FinancePeriod p) {
    _period = p;
    notifyListeners();
  }
}
