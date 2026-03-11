class Formatters {
  Formatters._();

  static String price(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} so\'m';
  }

  static String priceShort(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toString();
  }

  static String phone(String digits) {
    if (digits.length != 9) return '+998$digits';
    return '+998 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
  }

  static String date(DateTime dt) {
    final months = [
      '', 'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  static String dateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String weight(double value, String unit) {
    if (value == value.toInt().toDouble()) {
      return '${value.toInt()} $unit';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }
}