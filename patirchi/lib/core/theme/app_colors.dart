import 'package:flutter/material.dart';
import '../constants/enums.dart';

class AppColors {
  AppColors._();

  // PRIMARY — Brand Orange (from UI1 & UI2)
  static const Color primary = Color(0xFFFA6400);
  static const Color primaryDark = Color(0xFFF05A00);
  static const Color primaryLight = Color(0xFFFA7800);

  // SECONDARY — Warm Accent
  static const Color secondary = Color(0xFFE6A05A);
  static const Color secondaryLight = Color(0xFFE6AA78);

  // BACKGROUNDS
  static const Color scaffoldBg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color warmBg = Color(0xFFFAE6DC);
  static const Color warmBgLight = Color(0xFFFAF0DC);
  static const Color warmBgMedium = Color(0xFFF0E6D2);

  // Dark mode backgrounds
  static const Color scaffoldBgDark = Color(0xFF121212);
  static const Color cardBgDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF2C2C2C);

  // TEXT
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // STATUS / SEMANTIC
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ORDER STATUS BADGES
  static const Color statusNew = Color(0xFF2196F3);
  static const Color statusProgress = Color(0xFFFF9800);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  // ROLE ACCENTS
  static const Color buyerAccent = primary;
  static const Color bakeryAccent = Color(0xFF2979FF);
  static const Color supplierAccent = Color(0xFFE91E63);
  static const Color courierAccent = primary;

  // DIVIDER / BORDER
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  static Color roleAccent(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return buyerAccent;
      case UserRole.bakery:
        return bakeryAccent;
      case UserRole.supplier:
        return supplierAccent;
      case UserRole.courier:
        return courierAccent;
    }
  }

  static Color orderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return warning;
      case OrderStatus.confirmed:
        return statusNew;
      case OrderStatus.preparing:
        return statusProgress;
      case OrderStatus.delivering:
        return statusProgress;
      case OrderStatus.delivered:
        return statusDelivered;
      case OrderStatus.cancelled:
        return statusCancelled;
    }
  }
}