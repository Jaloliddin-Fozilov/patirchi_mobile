import 'package:flutter/material.dart';

enum NotificationType {
  order,
  promo,
  system;

  IconData get icon {
    switch (this) {
      case NotificationType.order:
        return Icons.receipt_long_rounded;
      case NotificationType.promo:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.order:
        return 'Buyurtma';
      case NotificationType.promo:
        return 'Aksiya';
      case NotificationType.system:
        return 'Tizim';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
