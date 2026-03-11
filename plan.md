# PATIRCHI MOBILE APP — Development Plan

## Status: PLANNING
> This file is our living plan. We discuss, update, and track decisions here.

---

## Phase 1: Project Setup & Architecture

### 1.1 Flutter Project Init
- [ ] Create Flutter project (`patirchi`)
- [ ] Folder structure (Clean Architecture / Feature-first)
- [ ] State management choice: **?** (Bloc / Riverpod / GetX — need to decide)
- [ ] DI setup (get_it + injectable)
- [ ] Router setup (go_router)

### 1.2 Core Dependencies
```
# Networking
dio, retrofit (or chopper)

# State Management
??? (TBD)

# Local Storage
shared_preferences, hive (or isar)

# Maps
google_maps_flutter / yandex_mapkit

# Notifications
firebase_messaging, flutter_local_notifications

# UI
lottie, shimmer, cached_network_image, flutter_svg

# Localization
easy_localization (uz-latin, uz-cyrillic, ru, en)

# Forms & Validation
flutter_form_builder, intl_phone_field

# Other
url_launcher, geolocator, permission_handler
```

### 1.3 Theming & Design System (adapted from UI1.jpg & UI2.jpg)

> **Reference**: tz_images/UI1.jpg (role selection onboarding) & tz_images/UI2.jpg (brand identity)
> Unified warm orange design language — primary brand identity for all roles.

- [ ] Light Mode
- [ ] Dark Mode

#### Color Palette (extracted from UI1 & UI2)
```
# PRIMARY — Brand Orange
primary:          #FA6400   (main orange — AppBar, buttons, highlights)
primaryDark:      #F05A00   (pressed/dark variant)
primaryLight:     #FA7800   (lighter variant)

# SECONDARY — Warm Accent
secondary:        #E6A05A   (warm gold — illustrations, accents)
secondaryLight:   #E6AA78   (soft warm — card accents, badges)

# BACKGROUNDS
scaffoldBg:       #FFFFFF   (main background)
cardBg:           #FFFFFF   (card surfaces)
warmBg:           #FAE6DC   (warm cream — section backgrounds, onboarding)
warmBgLight:      #FAF0DC   (lighter cream — subtle sections)
warmBgMedium:     #F0E6D2   (medium cream — input fields)

# TEXT
textPrimary:      #1A1A1A   (headings, main text)
textSecondary:    #6B6B6B   (descriptions, hints)
textOnPrimary:    #FFFFFF   (text on orange backgrounds)

# STATUS / SEMANTIC
success:          #4CAF50   (green checkmarks, confirmed)
error:            #F44336   (cancelled, errors)
warning:          #FFC107   (pending)
info:             #2196F3   (info, links)

# ORDER STATUS BADGES
statusNew:        #2196F3   (Yangi — blue filled)
statusProgress:   #FF9800   (Jarayonda — orange outline)
statusDelivered:  #4CAF50   (Yetkazilgan — green)
statusCancelled:  #F44336   (Qaytarilgan — red)
```

#### Role-Specific Accent Overrides
```
# Override sidebar/header gradients per role (brand orange stays for buyer/courier)
Buyer (Xaridor):       #FA6400 orange (default, no override)
Bakery (Nonvoy):       #2979FF blue (sidebar gradient, bottom bar active)
Supplier (Ta'minotchi): #E91E63 crimson (sidebar gradient, bottom bar active)
Courier (Yetkazuvchi):  #FA6400 orange (same as default)
```

#### UI Component Styles (from UI1)
```
AppBar:         solid #FA6400 background, white title, white icons
Buttons:
  - Primary:    filled #FA6400, white text, rounded-full (radius 25)
  - Secondary:  outlined #FA6400 border, orange text, rounded-full
  - Text:       no border, orange text
Cards:          white bg, rounded-16, subtle shadow (elevation 2-4)
Inputs:         rounded-12, #F0E6D2 fill, no visible border
Bottom Nav:     white bg, active = #FA6400 icon+label, inactive = gray
Sidebar:        gradient top→bottom using role accent color
Checkmarks:     green #4CAF50 circle for feature lists
Illustrations:  warm orange-toned vector/Lottie art
```

#### Typography
```
Headings:   Bold, #1A1A1A
Body:       Regular, #1A1A1A
Captions:   Regular, #6B6B6B
Prices:     SemiBold, #FA6400
Font:       System default (or Inter / Nunito for warmth)
```

---

## Phase 2: Authentication

### 2.1 Screens
- [ ] **Splash Screen** — Patirchi logo + Lottie animation
- [ ] **Role Selection** — 4 cards (Xaridor, Nonvoyxona, Yetkazuvchi, Ta'minotchi)
- [ ] **Login** — Phone (+998) / Email tabs, password field, "Kirish" button
- [ ] **Register** — Phone, name, password
- [ ] **OTP Verification** — 4-digit code input (SMS/Telegram), is next version, skip for now
- [ ] **Profile Setup** — Name, photo, role-specific fields

### 2.2 Logic
- Phone format: +998XXXXXXXXX (validator)
- Token storage (access + refresh)
- Auto-login on app restart
- Role switching from Profile (no re-auth needed?)

---

## Phase 3: Buyer (Xaridor) App

### 3.1 Navigation
Bottom bar: **Bozor** | **Katalog** | **Savat** | **Wishlist** | **Profil**

### 3.2 Screens
- [ ] **Bozor (Home)** — Search bar, popular bakeries, product listings, grid view
- [ ] **Katalog** — Circle image category slider + category grid with filters
- [ ] **Product Detail** — Image, name, price, weight, ingredients, "Savatga qo'shish"
- [ ] **Shop Page** — Name, owner, hours, logo, images, status, address on map, categories
- [ ] **Savat (Cart)** — Product list (+/-), coupon code, order summary, "Buyurtma Berish"
- [ ] **Checkout** — Delivery method toggle:
  - Topshirish punkti (pickup, free) — select bakery branch
  - Kuryer (courier, paid) — address input (map, kvartira, podyezd, qavat, eshik kodi)
- [ ] **My Orders** — Order list with status badges
- [ ] **Order Tracking** — Map view showing delivery location
- [ ] **Wishlist** — Saved products with hearts
- [ ] **Profile** — Avatar, stats, role switcher (4 quadrants), phone, address, settings

---

## Phase 4: Nonvoy (Bakery) App

### 4.1 Navigation
- **Sidebar**: Do'konlar, Buyurtmalar, Ombor, Moliya, Vakansiya, Statistika, Referal, Sozlamalar
- **Bottom bar**: Bozor | Buyurtma | Stats | Chat | Profil

### 4.2 Screens
- [ ] **Dashboard/Home** — Stats overview (orders count, revenue, avg, AI analysis)
- [ ] **Bozor** — Supplier products marketplace (browse & order raw materials)
- [ ] **Buyurtmalar Panel** — Tabs (Yangi, Jarayonda, Yetkazilgan, Qaytarilgan), filter, order cards
  - Toggle: "Kiruvchi buyurtma" / "Buyurtmalarim"
- [ ] **Order Detail** — Accept → Prepare → Deliver flow
- [ ] **Do'konlar** — List of owned shops + "Do'kon qo'shish +"
- [ ] **Shop Management** — Edit shop info, images, coordinates, hours
- [ ] **Products Management** — Product list inside shop, "Qo'shish +" to add new product
- [ ] **Product Form** — Name, price, weight, ingredients, image, active/inactive toggle
- [ ] **Ombor (Warehouse)** — Stock levels, raw material ordering from suppliers
- [ ] **Moliya (Finance)** — Income, outcome, balance
- [ ] **Statistika** — Bar charts, growth %, capital, profit mini-charts
- [ ] **Vakansiya** — Post/manage job listings
- [ ] **Referal** — Referral program
- [ ] **Sozlamalar** — App settings

---

## Phase 5: Ta'minotchi (Supplier) App

### 5.1 Navigation
- **Sidebar**: Do'konlar, Buyurtmalar, Moliya, Vakansiya, Statistika, Referal, Sozlamalar
- **Bottom bar**: Bozor | Buyurtma | Stats | Chat | Profil

### 5.2 Screens
- [ ] **Dashboard** — Revenue header, statistics bar chart, income/expense cards, capital/profit
- [ ] **Buyurtmalar Panel** — Same structure as Nonvoy (Jami, Tugatilgan, Daromad, O'rtacha)
- [ ] **Do'konlar** — Supplier shops list + "Do'kon qo'shish +"
- [ ] **Product Catalog** — Wholesale products (flour, sesame, oil, etc.), "Qo'shish +"
- [ ] **Product Form** — Name, price, weight, image, availability badge ("Mavjud")
- [ ] **Mijozlar (Clients)** — Bakery customers list
- [ ] **Moliya** — Financial overview
- [ ] **Statistika** — Analytics dashboard
- [ ] **Vakansiya** — Post job vacancies

---

## Phase 6: Yetkazuvchi (Courier) App

### 6.1 Screens
- [ ] **Available Orders** — Unassigned/assigned deliveries to accept
- [ ] **Active Delivery** — Map navigation (Google/Yandex) to destination
- [ ] **Delivery History** — Completed deliveries
- [ ] **Hamyon (Wallet)** — Daily/monthly earnings

---

## Phase 7: Common/Shared Features

- [ ] **Push Notifications (FCM)** — New order alerts for business owners
- [ ] **Localization** — O'zbek-lotin, O'zbek-krill, Русский
- [ ] **Offline Mode** — "Internet nofaol" screen, skeleton/shimmer loading
- [ ] **Error Handling** — Snackbar messages for 400/401/403/404/500
- [ ] **Pagination** — Infinity scroll on all lists (Products, Shops, Vacancies)
- [ ] **Social Feed** — Posts with photos, likes, comments, shares (community feature)
- [ ] **Vacancy Browser** — Filter by district, salary, education; contact button (phone call)
- [ ] **Maps Integration** — Location picker, auto-detect, shop addresses
- [ ] **Keyboard Types** — Number for price, text for name, phone for phone fields

---

## Shared Widgets (Reusable Components)

- [ ] `AppBottomBar` — Role-configurable bottom navigation
- [ ] `AppSidebar` — Role-configurable drawer menu
- [ ] `ProductCard` — Image, name, price, wishlist heart
- [ ] `OrderCard` — Order info with status badge
- [ ] `ShopCard` — Shop preview (logo, name, status, rating)
- [ ] `CategoryChip` — Horizontal scrollable filter chips
- [ ] `CircleCategorySlider` — Circle images for catalog categories
- [ ] `StatusBadge` — Colored label (Yangi, Jarayonda, etc.)
- [ ] `StatsCard` — Number + label + color (for dashboard)
- [ ] `SkeletonLoader` — Shimmer placeholders
- [ ] `EmptyState` — Lottie animation + message
- [ ] `ErrorState` — Lottie animation + retry button
- [ ] `PhoneInput` — +998 formatted phone field
- [ ] `OtpInput` — 4-digit code input
- [ ] `MapPicker` — Location selection with map
- [ ] `DeliveryToggle` — Pickup / Courier switcher

---

## Open Questions & Decisions Needed

1. **State Management**: Bloc vs Riverpod vs GetX?
2. **Map SDK**: Google Maps vs Yandex Maps vs Mapbox?
3. **Social Feed**: Is this a confirmed feature or future scope?
4. **Payment Integration**: Which payment provider? (Payme, Click, Uzum?)
5. **Chat**: Real-time chat between users? (WebSocket needed?)
6. **AI Tahlil**: What does the AI analysis button do on the orders panel?
7. **Referral System**: How does it work? Discount codes?
8. **Admin Approval**: How is shop approval (pending→active) handled in the app?
9. **Multi-shop**: Can one user own multiple shops?
10. **Courier Assignment**: Auto-assign or manual accept?

---

## Build Order (Suggested Priority)

```
1. Project setup + architecture + theming
2. Auth flow (splash → role → login → OTP → profile)
3. Buyer app (most users will be buyers)
4. Shared widgets library
5. Bakery owner app
6. Supplier app
7. Courier app
8. Push notifications + offline mode
9. Social feed + community
10. Polish, testing, optimization
```

---

## Phase 0: Build Preparation (CURRENT)

### Current System Status
```
[✓] Flutter 3.29.2 (stable) — installed at ~/flutter/
[✓] Dart 3.7.2
[✓] Project analyzes clean (0 errors, 0 warnings)
[✓] Provider dependency installed
[✓] 40 Dart files written, Clean Architecture
[✗] Android SDK — only platform-tools exist, missing cmdline-tools, build-tools, platforms
[✗] JDK — not installed (required for Android builds)
[✗] No emulator or physical device connected
[✗] Android Studio — not installed
[✗] Chrome — not found (for web debug)
```

### Step 1: Install JDK 17 (required)
```bash
sudo apt update && sudo apt install -y openjdk-17-jdk
```
Verify: `java -version` → should show 17.x

### Step 2: Install Android SDK components
```bash
# Set env vars (add to ~/.bashrc)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/flutter/bin

# Install cmdline-tools
mkdir -p $ANDROID_HOME/cmdline-tools
# Download from: https://developer.android.com/studio#command-line-tools-only
# Or use sdkmanager after installing Android Studio

# After cmdline-tools available:
sdkmanager "platforms;android-34" "build-tools;34.0.0" "cmdline-tools;latest"
sdkmanager --licenses   # accept all
```

### Step 3: Configure Android build
- [x] `applicationId` = `com.patirchi.patirchi` ✓
- [x] `minSdk` = flutter default (21) ✓
- [x] `compileSdk` = flutter default (34) ✓
- [ ] Update `applicationId` to `com.patirchi.app` (cleaner)
- [ ] Set `minSdk = 23` (Android 6.0, covers 95%+ devices)
- [ ] Add app icon (replace default Flutter icon)
- [ ] Add splash screen native config (Android 12+ splash)
- [ ] Configure release signing key

### Step 4: App Identity & Assets
- [ ] **App Icon**: Create 1024x1024 icon (Patirchi bakery logo)
  - Use `flutter_launcher_icons` package to generate all sizes
- [ ] **Splash Screen**: Native splash with logo
  - Use `flutter_native_splash` package
- [ ] **App Name**: Set display name to "Patirchi" in:
  - `android/app/src/main/AndroidManifest.xml` → android:label
  - `ios/Runner/Info.plist` → CFBundleDisplayName

### Step 5: Test Run Options
Pick one:
- **A) Physical Android device** (fastest):
  - Enable USB debugging → `flutter run`
- **B) Android Emulator**:
  - `sdkmanager "system-images;android-34;google_apis;x86_64"`
  - `avdmanager create avd -n patirchi_test -k "system-images;android-34;google_apis;x86_64"`
  - `flutter emulators --launch patirchi_test`
- **C) Web (Chrome)**:
  - `sudo apt install chromium-browser` or set CHROME_EXECUTABLE
  - `flutter run -d chrome`

### Step 6: First Build
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for sharing)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### Quick Path (minimum to get running)
```bash
# 1. Install JDK
sudo apt install -y openjdk-17-jdk

# 2. Install Android SDK via cmdline-tools
# (or just install Android Studio which bundles everything)

# 3. Accept licenses
flutter doctor --android-licenses

# 4. Run on connected device
flutter run
```

---

> **Action needed from you**:
> 1. Do you have a physical Android device to test with USB?
> 2. Do you want to install Android Studio (easy, bundles everything) or minimal SDK only?
> 3. Do you have the Patirchi logo for app icon?