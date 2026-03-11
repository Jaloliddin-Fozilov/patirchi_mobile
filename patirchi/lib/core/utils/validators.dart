class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Maydon']) {
    if (value == null || value.trim().isEmpty) {
      return '$field to\'ldirilishi shart';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqam kiriting';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 9) {
      return 'Telefon raqam 9 ta raqamdan iborat bo\'lishi kerak';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email kiriting';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email formati noto\'g\'ri';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parol kiriting';
    }
    if (value.length < 4) {
      return 'Parol kamida 4 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Parollar mos kelmadi';
    }
    return null;
  }
}