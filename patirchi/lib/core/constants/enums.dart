enum UserRole {
  buyer,
  bakery,
  supplier,
  courier;

  String get label {
    switch (this) {
      case UserRole.buyer:
        return 'Xaridor';
      case UserRole.bakery:
        return 'Nonvoyxona';
      case UserRole.supplier:
        return "Ta'minotchi";
      case UserRole.courier:
        return 'Yetkazuvchi';
    }
  }

  String get description {
    switch (this) {
      case UserRole.buyer:
        return 'Yaqin somsaxonlari toping';
      case UserRole.bakery:
        return 'Buyurtmalarni boshqaring';
      case UserRole.supplier:
        return 'Un va xom ashyo soting';
      case UserRole.courier:
        return 'Buyurtmalarni yetkazing';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivering,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Kutilmoqda';
      case OrderStatus.confirmed:
        return 'Tasdiqlangan';
      case OrderStatus.preparing:
        return 'Tayyorlanmoqda';
      case OrderStatus.delivering:
        return 'Yetkazilmoqda';
      case OrderStatus.delivered:
        return 'Yetkazilgan';
      case OrderStatus.cancelled:
        return 'Bekor qilingan';
    }
  }
}

enum ShopStatus {
  pending,
  active,
  inactive,
  blocked;
}

enum DeliveryMethod {
  pickup,
  courier;

  String get label {
    switch (this) {
      case DeliveryMethod.pickup:
        return 'Topshirish punkti';
      case DeliveryMethod.courier:
        return 'Kuryer';
    }
  }
}