class EarningModel {
  final int id;
  final int amount; // parsed from decimal string (90% of delivery_fee)
  final int commission; // parsed from decimal string (10% of delivery_fee)
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;

  const EarningModel({
    required this.id,
    required this.amount,
    required this.commission,
    required this.isPaid,
    this.paidAt,
    required this.createdAt,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: json['id'] as int,
      amount:
          (double.tryParse(json['amount']?.toString() ?? '0') ?? 0).toInt(),
      commission:
          (double.tryParse(json['commission']?.toString() ?? '0') ?? 0)
              .toInt(),
      isPaid: json['is_paid'] as bool? ?? false,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  bool get isPositive => amount >= 0;
}

class EarningPeriod {
  final int total;
  final int count;

  const EarningPeriod({
    required this.total,
    required this.count,
  });

  factory EarningPeriod.fromJson(Map<String, dynamic> json) {
    return EarningPeriod(
      total:
          (double.tryParse(json['total']?.toString() ?? '0') ?? 0).toInt(),
      count: json['count'] as int? ?? 0,
    );
  }

  static const EarningPeriod empty = EarningPeriod(total: 0, count: 0);
}

class EarningsSummary {
  final EarningPeriod daily;
  final EarningPeriod weekly;
  final EarningPeriod monthly;

  const EarningsSummary({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      daily: json['daily'] != null
          ? EarningPeriod.fromJson(json['daily'] as Map<String, dynamic>)
          : EarningPeriod.empty,
      weekly: json['weekly'] != null
          ? EarningPeriod.fromJson(json['weekly'] as Map<String, dynamic>)
          : EarningPeriod.empty,
      monthly: json['monthly'] != null
          ? EarningPeriod.fromJson(json['monthly'] as Map<String, dynamic>)
          : EarningPeriod.empty,
    );
  }

  static const EarningsSummary empty = EarningsSummary(
    daily: EarningPeriod.empty,
    weekly: EarningPeriod.empty,
    monthly: EarningPeriod.empty,
  );
}
