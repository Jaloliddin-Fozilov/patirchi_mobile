import 'package:flutter/material.dart';
import 'package:patirchi/features/notification/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Buyurtmangiz yo\'lda!',
      message: 'Buyurtma #10234 kuryer tomonidan olib ketildi. Taxminiy yetkazish: 30 daqiqa.',
      type: NotificationType.order,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Buyurtma tasdiqlandi',
      message: 'Buyurtma #10234 do\'kon tomonidan tasdiqlandi va tayyorlanmoqda.',
      type: NotificationType.order,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Yangi aksiya! 20% chegirma',
      message: 'Toshkent Non do\'konidan barcha patir nonlarga 20% chegirma. Bugun kechgacha!',
      type: NotificationType.promo,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Buyurtma yetkazildi',
      message: 'Buyurtma #10233 muvaffaqiyatli yetkazildi. Xaridingizdan mamnunmisiz?',
      type: NotificationType.order,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    NotificationModel(
      id: 'n5',
      title: 'Xush kelibsiz!',
      message: 'Patirchi ilovasi orqali eng mazali nonlarni topib olishingiz mumkin. Bozorni ko\'ring!',
      type: NotificationType.system,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    ),
    NotificationModel(
      id: 'n6',
      title: 'Sevimli do\'kon yangilik!',
      message: 'Samarqand Noni yangi assortiment qo\'shdi: Varaki somsa va Buxoro nonlari.',
      type: NotificationType.promo,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      id: 'n7',
      title: 'Buyurtma bekor qilindi',
      message: 'Buyurtma #10220 do\'kon tomonidan bekor qilindi. Uzr, boshqa buyurtma bering.',
      type: NotificationType.order,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    NotificationModel(
      id: 'n8',
      title: 'Profil to\'ldirilsin',
      message: 'Profil ma\'lumotlaringizni to\'ldiring va birinchi buyurtmada 15% chegirma oling!',
      type: NotificationType.system,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    bool changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
