enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String description;
  final int amount;
  final TransactionType type;
  final String category;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;
}
