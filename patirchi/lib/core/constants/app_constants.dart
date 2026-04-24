class AppConstants {
  AppConstants._();

  static const String appName = 'Patirchi';
  static const String appVersion = '1.0.0';

  // API backend
  static const String baseUrl = 'https://app.patirchi.uz/api/v1';

  // Phone
  static const String phonePrefix = '+998';
  static const int phoneLength = 9;
  static const int otpLength = 4;

  // Pagination
  static const int pageSize = 20;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 25.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMed = 4.0;
  static const double elevationHigh = 8.0;
}