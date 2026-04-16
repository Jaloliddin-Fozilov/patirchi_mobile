# CLAUDE.md — Patirchi Mobile

## CRITICAL CONSTRAINT
**HECH QACHON run, build, yoki test buyruqlarini ishlatma.**
Bloklangan: `flutter build *`, `flutter run *`, `flutter test *`, `dart run`, `pub get`, `flutter pub get`
Ruxsat: fayllarni o'qish, tahrirlash, `dart format`, `dart analyze`

## Loyiha

O'zbekiston non bozori ekotizimi — Flutter mobile app. 4 rol: Buyer, Bakery, Supplier, Courier.

**Tech stack:** Flutter 3.x, Dart ^3.7.2, Provider, Yandex MapKit, Material 3
**Statistika:** 132 fayl, ~29,700 qator Dart kodi
**Backend:** Django REST Framework + JWT + OTP (patirchi_mini_app repo)

## Tuzilma

```
patirchi/lib/
├── main.dart                    # Entry + routing + 18 ta Provider
├── core/
│   ├── constants/               # app_constants, enums
│   ├── error/                   # failures (sealed), result (Result<T>)
│   ├── network/                 # api_client, api_endpoints, api_exception
│   ├── repositories/            # base_repository (safeApiCall)
│   ├── storage/                 # secure_storage_service
│   ├── theme/                   # app_colors, app_theme, theme_provider
│   ├── utils/                   # formatters, validators
│   └── widgets/                 # 12 shared widget (product_card, order_card, etc.)
└── features/
    ├── auth/                    # login, register, splash, role selection
    │   └── data/repositories/   # auth_repository
    ├── buyer/
    │   ├── home/                # home screen, product detail, shop detail, nearby map
    │   ├── catalog/             # category browsing
    │   ├── cart/                # cart + checkout_request_model
    │   ├── checkout/            # checkout screen + success screen
    │   ├── orders/              # buyer order history + detail + timeline
    │   ├── address/             # address CRUD
    │   └── wishlist/            # favorites grid
    ├── bakery/
    │   ├── dashboard/           # stats + revenue
    │   ├── orders/              # order management + detail + status transitions
    │   ├── menu/                # product CRUD (add/edit/delete)
    │   ├── inventory/           # stock management with color-coded levels
    │   ├── finance/             # income/expense/profit + transactions
    │   └── marketplace/         # order raw materials from suppliers
    ├── supplier/
    │   ├── products/            # raw material catalog CRUD
    │   ├── orders/              # incoming orders from bakeries
    │   └── stats/               # sales analytics
    ├── courier/
    │   ├── deliveries/          # available/active/completed deliveries
    │   └── wallet/              # earnings + balance + transactions
    ├── chat/                    # conversations + messages (all roles)
    ├── notification/            # grouped notifications + read/unread
    └── profile/                 # profile + settings (shared)
```

## 18 ta Provider (MultiProvider)

| Provider | Fayl | Vazifasi |
|----------|------|----------|
| `AuthProvider` | auth/providers/ | Login, register, role switch, logout |
| `BuyerHomeProvider` | buyer/home/providers/ | Products, shops, search, pagination, favorites |
| `CartProvider` | buyer/cart/providers/ | Cart items, qty, coupon, delivery, totals |
| `CheckoutProvider` | buyer/checkout/providers/ | Payment method, place order |
| `OrdersProvider` | buyer/orders/providers/ | Buyer order history, cancel, reorder |
| `AddressProvider` | buyer/address/providers/ | Address CRUD, default selection |
| `NotificationProvider` | notification/providers/ | Notifications, mark read, unread count |
| `BakeryOrdersProvider` | bakery/orders/providers/ | Order status machine (confirm→prepare→deliver) |
| `MenuProvider` | bakery/menu/providers/ | Menu CRUD, search, category filter |
| `InventoryProvider` | bakery/inventory/providers/ | Stock levels, reorder |
| `FinanceProvider` | bakery/finance/providers/ | Transactions, income/expense/profit |
| `ChatProvider` | chat/providers/ | Conversations, messages, unread |
| `SupplierProductsProvider` | supplier/products/providers/ | Raw material CRUD |
| `SupplierOrdersProvider` | supplier/orders/providers/ | Incoming bakery orders |
| `SupplierStatsProvider` | supplier/stats/providers/ | Sales analytics |
| `CourierProvider` | courier/deliveries/providers/ | Online toggle, deliveries |
| `WalletProvider` | courier/wallet/providers/ | Earnings, balance, transactions |
| `ThemeProvider` | core/theme/ | Light/Dark mode toggle |

## Konvensiyalar

### State Management
- `ChangeNotifier` + `Provider` pattern
- Yangi state → yangi `ChangeNotifier` yaratib `MultiProvider`ga qo'sh

### Routing
- Named routes: `/`, `/role-selection`, `/login`, `/register`, `/otp`, `/home`, `/checkout`, `/orders`, `/addresses`, `/notifications`
- `onGenerateRoute` in `main.dart`
- `/otp` route: `settings.arguments as String` — phone number uzatiladi
- Ichki ekranlar: `Navigator.push(MaterialPageRoute(...))`

### Backend integratsiya (REAL API)
- **Base URL:** `https://api.patirchi.uz/api/v1`
- **Auth:** JWT tokens (OTP-based login)
- **Auth flow:** login(phone,role) → secret → confirmOtp(secret,otp) → JWT tokens → getMe()
- **ApiClient:** auto token injection, auto 401 refresh, DRF pagination, multipart upload
- **Pagination:** `?limit=20&offset=0` → `{count, next, previous, results}`
- **Prices:** Backend Decimal strings ("5000.00") → `int` for display
- **Fallback:** API xato bo'lganda mock data'ga fallback (graceful degradation)
- **Rollar mapping:** buyer=ordinary, bakery=business(store_type=bakery), supplier=business(store_type=supplier), courier=delivery profile
- Repository pattern: `Provider → Repository → ApiClient` (all wrapped in `safeApiCall → Result<T>`)
- Model'lar: `fromJson`/`fromApiJson`/`fromListJson` factory'lar bilan

### Dizayn
- Brand rang: `AppColors.primary` = `#FA6400`
- Light + Dark tema: `AppTheme.light()` / `AppTheme.dark()`
- Rol ranglar: buyer=orange, bakery=blue (#2979FF), supplier=pink (#E91E63), courier=orange
- Shared widgets: `core/widgets/` — 12 ta reusable component

### Enums
- `UserRole`: buyer, bakery, supplier, courier
- `OrderStatus`: pending, confirmed, preparing, delivering, delivered, cancelled
- `DeliveryMethod`: pickup, courier
- `PaymentMethod`: cash, payme, click, uzum (checkout_provider)
- `NotificationType`: order, promo, system
- `TransactionType`: income, expense
- `DeliveryStatus`: available, pickedUp, delivering, delivered

### Fayl nomlash
- Ekranlar: `*_screen.dart`
- Provider'lar: `*_provider.dart`
- Model'lar: `*_model.dart`
- Repository'lar: `*_repository.dart`
- Datasource'lar: `*_local_datasource.dart`
- Shell'lar: `*_shell.dart`

## Backend integratsiya

- `backend_changes.md` — to'liq API hujjat (50+ endpoint, 21 jadval, WebSocket events)
- `core/network/api_endpoints.dart` — barcha endpoint path'lar
- `core/network/api_client.dart` — HTTP client (dart:io based, dio ga swap qilinadigan)
- `core/storage/secure_storage_service.dart` — token storage (in-memory, flutter_secure_storage ga swap)
- `core/error/` — `Failure` sealed hierarchy + `Result<T>` type

## Nima qoldi

### Hali kerak
- Push notifications (Firebase)
- Localization (i18n) — hozir barcha matnlar hardcoded o'zbek
- Image caching (`cached_network_image` — hozir `Image.network` bilan)
- Offline support (local DB — hozir mock fallback bor)
- Deep linking
- Tests (0% coverage)
- Bakery/Supplier order status update endpoint (backend'da yo'q — lokal state bilan ishlaydi)

## Muhim fayllar
- `main.dart` — app entry, 18 provider, 10 named route
- `core/network/api_client.dart` — HTTP client (auto-token, refresh, pagination, multipart)
- `core/network/api_endpoints.dart` — 50+ real backend endpoint path'lar
- `core/error/result.dart` — Result<T> sealed class
- `core/repositories/base_repository.dart` — safeApiCall wrapper
- `core/storage/secure_storage_service.dart` — JWT token storage
- `features/auth/data/repositories/auth_repository.dart` — OTP login, JWT, getMe()
- `features/buyer/home/data/repositories/buyer_repository.dart` — products, shops, categories
- `features/buyer/cart/data/repositories/cart_repository.dart` — cart CRUD, checkout
- `features/bakery/data/repositories/bakery_repository.dart` — store orders, menu CRUD
- `features/supplier/data/repositories/supplier_repository.dart` — supplier products, orders
- `features/courier/data/repositories/courier_repository.dart` — deliveries, earnings, profile
- `backend_changes.md` — backend uchun to'liq texnik hujjat
