# Patirchi Mobile — Init

## Loyiha haqida

**Patirchi** — O'zbekiston non bozorining raqamli ekotizimi. Non, somsa, patir va boshqa novvoyxona mahsulotlarini onlayn buyurtma qilish, yetkazish va boshqarish platformasi.

- **Flutter** (Dart SDK ^3.7.2)
- **Versiya:** 1.0.0+1
- **Paket nomi:** `com.patirchi.patirchi`
- **Holat:** MVP/Prototype — lokal ma'lumotlar bilan ishlaydi, backend integratsiyasi hali yo'q

## Arxitektura

### Feature-Based + Clean Architecture (Soddalashtirilgan)

```
patirchi/lib/
├── main.dart                    # App entry, MultiProvider, routing
├── core/
│   ├── constants/
│   │   ├── app_constants.dart   # API URL, animation durations, radius, pagination
│   │   └── enums.dart           # UserRole, OrderStatus, ShopStatus, DeliveryMethod
│   ├── theme/
│   │   ├── app_colors.dart      # Brand colors, role accents, status colors
│   │   ├── app_theme.dart       # Material3 light/dark ThemeData
│   │   └── theme_provider.dart  # ThemeMode toggle (ChangeNotifier)
│   ├── utils/
│   │   ├── formatters.dart      # price(), phone(), date(), weight()
│   │   └── validators.dart      # required(), phone(), email(), password()
│   └── widgets/                 # Reusable UI components
│       ├── app_sidebar.dart     # Expandable drawer with nested menu items
│       ├── category_chip.dart   # Horizontal scrollable filter chips
│       ├── empty_state.dart     # Icon + title + subtitle + optional action
│       ├── order_card.dart      # Order summary card with status badge
│       ├── phone_input.dart     # +998 prefixed phone input with formatter
│       ├── product_card.dart    # Product grid card with price, discount, favorite
│       ├── shimmer_loading.dart # Animated shimmer placeholder (list + grid)
│       ├── stats_card.dart      # Statistics card with icon and change indicator
│       └── status_badge.dart    # Colored pill badge (solid/outlined)
└── features/
    ├── auth/                    # Authentication flow
    ├── buyer/                   # Xaridor (Buyer) — main consumer flow
    ├── bakery/                  # Nonvoyxona (Bakery) — business dashboard
    ├── supplier/                # Ta'minotchi (Supplier) — ingredient sales
    ├── courier/                 # Yetkazuvchi (Courier) — delivery
    └── profile/                 # Profile + Settings (shared across roles)
```

### Feature ichki tuzilishi

```
features/<feature>/
├── data/
│   ├── datasources/    # Lokal mock datasource'lar
│   └── models/         # Data model'lar (plain Dart classes)
└── presentation/
    ├── providers/      # ChangeNotifier state management
    └── screens/        # UI ekranlar
```

## 4 ta Rol (Multi-Role System)

| Rol | Shell | Tabs | Holat |
|-----|-------|------|-------|
| **Buyer** (Xaridor) | `BuyerShell` | Bozor, Katalog, Savatcha, Sevimli, Profil | To'liq UI |
| **Bakery** (Nonvoyxona) | `BakeryShell` | Bozor, Buyurtma, Statistika, Chat, Profil | Dashboard + Orders |
| **Supplier** (Ta'minotchi) | `SupplierShell` | Bozor, Buyurtma, Statistika, Chat, Profil | Placeholder |
| **Courier** (Yetkazuvchi) | `CourierShell` | Buyurtmalar, Hamyon, Profil | Placeholder |

Rol tanlash: `RoleSelectionScreen` → `LoginScreen` → `_HomeRouter` (rol bo'yicha shell)

## State Management

**Provider** (`provider: ^6.1.2`) — `ChangeNotifier` pattern:

| Provider | Vazifasi |
|----------|----------|
| `AuthProvider` | Login, register, role switching, logout |
| `BuyerHomeProvider` | Mahsulotlar, do'konlar, search, pagination, favorites |
| `CartProvider` | Savat items, quantity, coupon, delivery method, totals |
| `ThemeProvider` | Light/Dark mode toggle |

## Ma'lumotlar holati

- **Hamma narsa lokal** — `AuthLocalDatasource`, `BuyerHomeLocalDatasource`
- **API tayyor emas** — `AppConstants.baseUrl = 'https://api.patirchi.uz/api/v1'` (placeholder)
- Mock data: 12 ta mahsulot, 6 ta do'kon (Toshkent koordinatalari bilan)
- Rasmlar: Unsplash URL'lar orqali (`Image.network`)

## Asosiy Dependencies

| Paket | Versiya | Maqsad |
|-------|---------|--------|
| `provider` | ^6.1.2 | State management |
| `yandex_mapkit` | ^4.0.0 | Xarita (yaqin do'konlar) |
| `cupertino_icons` | ^1.0.8 | iOS style ikonlar |
| `flutter_lints` | ^5.0.0 | Lint qoidalar |

## Routing

`onGenerateRoute` (named routes):

| Route | Screen |
|-------|--------|
| `/` | `SplashScreen` |
| `/role-selection` | `RoleSelectionScreen` |
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` |
| `/home` | `_HomeRouter` (role-based) |

Ichki navigatsiya: `Navigator.push(MaterialPageRoute(...))` — declarative routing yo'q.

## Dizayn tizimi

- **Brand rangi:** `#FA6400` (Orange)
- **Material 3** enabled
- **Light + Dark** theme
- Rol-specific accent ranglar: Buyer=orange, Bakery=blue, Supplier=pink, Courier=orange
- Custom bottom nav (BuyerShell), standart `BottomNavigationBar` (boshqalar)
- Warm background tonlar: `#FAE6DC`, `#FAF0DC`, `#F0E6D2`

## Asosiy ekranlar (Buyer flow — eng to'liq)

1. **BuyerHomeScreen** — dark theme, collapsing sliver header, promo banners carousel, quick services, product grid with infinite scroll + pull-to-refresh
2. **ProductDetailScreen** — rasm, narx, tarkib, tavsif, add-to-cart
3. **NearbyShopsMapScreen** — Yandex Maps, custom marker rendering (Canvas), horizontal shop carousel
4. **ShopDetailScreen** — do'kon info, mahsulotlar ro'yxati, cart bottom bar
5. **CatalogScreen** — kategoriyalar grid, cuisine types, featured cards
6. **CartScreen** — savat items, coupon input, to'lov xulosasi
7. **WishlistScreen** — sevimli mahsulotlar grid
8. **ProfileScreen** — foydalanuvchi info, role switcher, stats

## Tillar

- **UI tili:** O'zbek (Lotin)
- Barcha label'lar hardcoded (i18n hali yo'q)
- `assets/translations/` papkasi mavjud lekin bo'sh

## Platformalar

- Android (asosiy), iOS, Web, Linux, macOS, Windows — Flutter multi-platform
- Android: INTERNET + FINE_LOCATION + COARSE_LOCATION permissions
- Yandex MapKit native integratsiya

## Statistika

- **46 ta Dart fayl**
- **~5,500 qator kod** (taxminan)
- **0 ta test** (faqat default widget_test.dart)
- **0 ta generated file** (freezed, json_serializable yo'q)
