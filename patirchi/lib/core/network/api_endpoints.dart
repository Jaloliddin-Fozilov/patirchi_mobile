/// Barcha API endpoint yo'llari statik konstantalar sifatida.
///
/// Yo'llar [AppConstants.baseUrl] bilan birlashtirib ishlatiladi.
/// Misol: `AppConstants.baseUrl + ApiEndpoints.login`
class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// POST — telefon va rol bilan OTP yuborish.
  static const String login = '/auth/login/';

  /// POST — OTP kodni tasdiqlash va token olish.
  static const String loginConfirm = '/auth/login/confirm/';

  /// POST — access/refresh token olish (username/password).
  static const String token = '/auth/token/';

  /// POST — access tokenni refresh token orqali yangilash.
  static const String tokenRefresh = '/auth/token/refresh/';

  /// GET — joriy foydalanuvchi profili.
  static const String me = '/auth/me/';

  /// POST — yangi hisob yaratish.
  static const String signup = '/auth/signup/';

  // ---------------------------------------------------------------------------
  // Site — Do'konlar
  // ---------------------------------------------------------------------------

  /// GET — barcha do'konlar ro'yxati.
  static const String storesAll = '/site/stores/all/';

  /// GET — foydalanuvchi do'konlari.
  static const String myStores = '/site/stores/';

  /// POST — yangi do'kon yaratish.
  static const String storeCreate = '/site/stores/create/';

  // ---------------------------------------------------------------------------
  // Site — Kategoriyalar va Mahsulotlar
  // ---------------------------------------------------------------------------

  /// GET — kategoriyalar ro'yxati.
  static const String categories = '/site/categories/';

  /// GET — mahsulotlar ro'yxati.
  static const String products = '/site/products/';

  /// GET/PUT/DELETE — bitta mahsulot.
  static String productDetail(int id) => '/site/products/$id/';

  /// POST — do'konga mahsulot qo'shish.
  static String productCreate(int storeId) =>
      '/site/stores/$storeId/products/create/';

  // ---------------------------------------------------------------------------
  // Site — Ta'minotchi mahsulotlari
  // ---------------------------------------------------------------------------

  /// GET — ta'minotchi mahsulotlari ro'yxati.
  static const String supplierProducts = '/site/supplier-products/';

  /// GET/PUT/DELETE — bitta ta'minotchi mahsuloti.
  static String supplierProductDetail(int id) =>
      '/site/supplier-products/$id/';

  /// POST — do'kon uchun ta'minotchi mahsulot yaratish.
  static String supplierProductCreate(int storeId) =>
      '/site/stores/$storeId/supplier-products/create/';

  // ---------------------------------------------------------------------------
  // Site — Savatcha
  // ---------------------------------------------------------------------------

  /// GET — savatchani ko'rish.
  static const String cart = '/site/cart/';

  /// POST — savatchaga mahsulot qo'shish.
  static const String cartAdd = '/site/cart/add/';

  /// PUT — savatchadagi elementni yangilash.
  static String cartUpdate(int itemId) => '/site/cart/update/$itemId/';

  /// DELETE — savatchadan o'chirish.
  static String cartRemove(int pk) => '/site/cart/remove/$pk/';

  // ---------------------------------------------------------------------------
  // Site — Buyurtmalar
  // ---------------------------------------------------------------------------

  /// POST — buyurtma berish.
  static const String orderCreate = '/site/order/create/';

  /// GET — xaridorning buyurtmalari.
  static const String myOrders = '/site/orders/';

  /// GET — do'kon buyurtmalari.
  static const String storeOrders = '/site/store/orders/';

  /// GET — ta'minotchi buyurtmalari.
  static const String supplierOrders = '/site/supplier/orders/';

  // ---------------------------------------------------------------------------
  // Site — Vakansiyalar
  // ---------------------------------------------------------------------------

  /// GET — vakansiyalar ro'yxati.
  static const String vacancies = '/site/vacancies/';

  /// GET — bitta vakansiya.
  static String vacancyDetail(int id) => '/site/vacancies/$id/';

  /// PUT — vakansiyani yangilash.
  static String vacancyUpdate(int id) => '/site/vacancies/update/$id/';

  /// DELETE — vakansiyani o'chirish.
  static String vacancyDelete(int id) => '/site/vacancies/delete/$id/';

  /// POST — yangi vakansiya yaratish.
  static const String vacancyCreate = '/site/vacancies/create/';

  // ---------------------------------------------------------------------------
  // Delivery — Kuryer
  // ---------------------------------------------------------------------------

  /// GET/PUT — kuryer profili.
  static const String deliveryProfile = '/site/delivery/profile/';

  /// POST — kuryer statusini almashtirish (online/offline).
  static const String deliveryToggle = '/site/delivery/toggle-status/';

  /// GET — mavjud buyurtmalar (kuryer uchun).
  static const String deliveryAvailable = '/site/delivery/orders/available/';

  /// GET — aktiv yetkazishlar.
  static const String deliveryActive = '/site/delivery/orders/active/';

  /// GET — yetkazish tarixi.
  static const String deliveryHistory = '/site/delivery/orders/history/';

  /// GET — bitta yetkazish tafsilotlari.
  static String deliveryDetail(int id) => '/site/delivery/orders/$id/';

  /// POST — yetkazish harakati (accept, pickup, deliver, etc.).
  static String deliveryAction(int id, String action) =>
      '/site/delivery/orders/$id/$action/';

  /// GET — kuryer daromadlari.
  static const String deliveryEarnings = '/site/delivery/earnings/';

  /// GET — kuryer daromadlari xulosasi.
  static const String deliveryEarningsSummary =
      '/site/delivery/earnings/summary/';

  // ---------------------------------------------------------------------------
  // Obuna
  // ---------------------------------------------------------------------------

  /// GET — obuna rejalari.
  static const String subscriptionPlans = '/site/subscription/plans/';

  /// GET — joriy obuna.
  static const String subscriptionMy = '/site/subscription/my/';

  /// POST — obuna sotib olish.
  static const String subscriptionSubscribe = '/site/subscription/subscribe/';

  // ---------------------------------------------------------------------------
  // Jihozlar (Equipment)
  // ---------------------------------------------------------------------------

  /// GET — jihozlar kategoriyalari.
  static const String equipmentCategories = '/site/equipment-categories/';

  /// GET — jihozlar ro'yxati.
  static const String equipments = '/site/equipments/';

  /// GET — bitta jihoz.
  static String equipmentDetail(int id) => '/site/equipments/$id/';

  // ---------------------------------------------------------------------------
  // Ijara (Rent)
  // ---------------------------------------------------------------------------

  /// GET — barcha ijaralar.
  static const String rents = '/site/rents/';

  /// GET — foydalanuvchi ijaralari.
  static const String myRents = '/site/rents/my/';

  /// GET — bitta ijara.
  static String rentDetail(int id) => '/site/rents/$id/';

  /// POST — yangi ijara yaratish.
  static const String rentCreate = '/site/rents/create/';

  // ---------------------------------------------------------------------------
  // Reels
  // ---------------------------------------------------------------------------

  /// GET — reels ro'yxati.
  static const String reels = '/site/reels/';

  /// POST — reelga like bosish.
  static String reelLike(int id) => '/site/reels/$id/like/';

  /// GET/POST — reel izohlari.
  static String reelComments(int id) => '/site/reels/$id/comments/';

  /// POST — reel ko'rishni qayd etish.
  static String reelView(int id) => '/site/reels/$id/view/';
}
