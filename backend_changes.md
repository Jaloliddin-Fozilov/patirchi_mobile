# Patirchi Backend — To'liq Texnik Hujjat

> Bu hujjat backend dasturchi uchun yozilgan. Flutter mobile app kodini tahlil qilib,
> backend API ni noldan qurish uchun zarur bo'lgan barcha ma'lumotlar shu yerda.

---

## 1. API Architecture Overview

### Base URL
```
https://api.patirchi.uz/api/v1
```

### Authentication
- JWT (JSON Web Token) — access token + refresh token juftligi
- Access token umri: **15 daqiqa**
- Refresh token umri: **30 kun**
- Header format: `Authorization: Bearer <access_token>`
- Token yangilash: `POST /auth/refresh` (refresh token bilan)

### Request / Response Format
- Content-Type: `application/json`
- Barcha so'rovlar va javoblar UTF-8 JSON

### Standard Response Envelope
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": null
}
```

Xato holati:
```json
{
  "success": false,
  "data": null,
  "error": "Foydalanuvchi topilmadi.",
  "code": "USER_NOT_FOUND"
}
```

Paginated javob:
```json
{
  "success": true,
  "data": [ ... ],
  "error": null,
  "meta": {
    "total": 120,
    "page": 1,
    "pageSize": 20,
    "hasMore": true
  }
}
```

### Pagination
- **Offset-based**: `?page=1&pageSize=20` (default pageSize: 20)
- Mobile home screen: `pageSize=6` (kichik batch, infinite scroll uchun)

### Error Codes (backend qaytaradigan `code` qiymatlari)
| Code | HTTP | Ma'no |
|------|------|-------|
| `VALIDATION_ERROR` | 400 | So'rov ma'lumotlari noto'g'ri |
| `UNAUTHORIZED` | 401 | Token yo'q yoki yaroqsiz |
| `FORBIDDEN` | 403 | Ruxsat yo'q |
| `NOT_FOUND` | 404 | Resurs topilmadi |
| `CONFLICT` | 409 | Allaqachon mavjud (masalan, telefon raqami) |
| `UNPROCESSABLE` | 422 | Ma'lumotlar noto'g'ri formatda |
| `TOO_MANY_REQUESTS` | 429 | Rate limit oshib ketdi |
| `SERVER_ERROR` | 500 | Ichki server xatosi |
| `TIMEOUT` | 408 | So'rov vaqti tugadi |

---

## 2. Database Schema

> Tavsiya etilgan texnologiya: **PostgreSQL**. UUID primary keys, `created_at` / `updated_at` barcha tablalarda.

---

### 2.1 `users`
```sql
CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         VARCHAR(100) NOT NULL,
  phone        VARCHAR(20)  NOT NULL UNIQUE,  -- "+998901234567"
  email        VARCHAR(255),
  password_hash VARCHAR(255),                 -- bcrypt
  avatar_url   TEXT,
  role         VARCHAR(20)  NOT NULL DEFAULT 'buyer',
                             -- 'buyer' | 'bakery' | 'supplier' | 'courier'
  is_active    BOOLEAN      NOT NULL DEFAULT true,
  fcm_token    TEXT,                          -- Firebase push notification token
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role  ON users(role);
```

**Eslatma:** Bir foydalanuvchi bir vaqtning o'zida faqat bitta rolda ishlaydi. Rol almashtirish `/auth/switch-role` orqali.

---

### 2.2 `otp_codes`
```sql
CREATE TABLE otp_codes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone      VARCHAR(20)  NOT NULL,
  code       VARCHAR(10)  NOT NULL,
  expires_at TIMESTAMPTZ  NOT NULL,
  is_used    BOOLEAN      NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_phone ON otp_codes(phone);
```

---

### 2.3 `refresh_tokens`
```sql
CREATE TABLE refresh_tokens (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ  NOT NULL,
  is_revoked BOOLEAN      NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
```

---

### 2.4 `categories`
```sql
CREATE TABLE categories (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(100) NOT NULL,  -- "Tandir non", "Patir", "Somsa"
  slug       VARCHAR(100) NOT NULL UNIQUE,
  icon_url   TEXT,
  sort_order INT          NOT NULL DEFAULT 0,
  is_active  BOOLEAN      NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
```

Seed data (mobile appdagi kategoriyalar asosida):
- `Barchasi` (special — frontend filter uchun, DB'da saqlanmasligi mumkin)
- `Nonushta`
- `Tandir non`
- `Patir`
- `Somsa`
- `Shirin`
- `Lavash`

---

### 2.5 `shops`
```sql
CREATE TABLE shops (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID        NOT NULL REFERENCES users(id),
  name        VARCHAR(200) NOT NULL,
  logo_url    TEXT,
  shop_type   VARCHAR(20)  NOT NULL DEFAULT 'bakery',
               -- 'bakery' | 'supplier'
  status      VARCHAR(20)  NOT NULL DEFAULT 'pending',
               -- 'pending' | 'active' | 'inactive' | 'blocked'
  address     TEXT,
  district    VARCHAR(100),
  latitude    DECIMAL(10, 7),
  longitude   DECIMAL(10, 7),
  open_time   TIME,   -- "08:00"
  close_time  TIME,   -- "22:00"
  rating      DECIMAL(3, 2) DEFAULT 0.00,
  rating_count INT           DEFAULT 0,
  is_open     BOOLEAN       NOT NULL DEFAULT false,
               -- Bu computed yoki manual toggle bo'lishi mumkin
  description TEXT,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shops_owner_id  ON shops(owner_id);
CREATE INDEX idx_shops_status    ON shops(status);
CREATE INDEX idx_shops_shop_type ON shops(shop_type);
-- Geospatial queries uchun:
CREATE INDEX idx_shops_location  ON shops USING GIST(
  ST_MakePoint(longitude, latitude)
);
```

---

### 2.6 `shop_images`
```sql
CREATE TABLE shop_images (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id    UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  url        TEXT NOT NULL,
  sort_order INT  NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shop_images_shop_id ON shop_images(shop_id);
```

---

### 2.7 `products`
```sql
CREATE TABLE products (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id          UUID         NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  category_id      UUID         REFERENCES categories(id),
  name             VARCHAR(200) NOT NULL,
  description      TEXT,
  price            INT          NOT NULL,  -- so'm, decimal yo'q
  old_price        INT,
  discount_percent INT,
  weight           DECIMAL(8, 2),
  weight_unit      VARCHAR(20)  DEFAULT 'dona',  -- 'g' | 'kg' | 'dona'
  ingredients      TEXT[],                        -- PostgreSQL array
  image_url        TEXT,
  is_available     BOOLEAN      NOT NULL DEFAULT true,
  sort_order       INT          NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_shop_id     ON products(shop_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_is_available ON products(is_available);
-- Full-text search uchun:
CREATE INDEX idx_products_name_fts ON products USING GIN(to_tsvector('russian', name));
```

---

### 2.8 `orders`
```sql
CREATE TABLE orders (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number     BIGSERIAL UNIQUE,               -- auto-increment, frontend'da ko'rsatiladi
  buyer_id         UUID         NOT NULL REFERENCES users(id),
  shop_id          UUID         NOT NULL REFERENCES shops(id),
  status           VARCHAR(20)  NOT NULL DEFAULT 'pending',
                   -- 'pending' | 'confirmed' | 'preparing' | 'delivering' | 'delivered' | 'cancelled'
  delivery_method  VARCHAR(20)  NOT NULL DEFAULT 'pickup',
                   -- 'pickup' | 'courier'
  delivery_address TEXT,
  delivery_lat     DECIMAL(10, 7),
  delivery_lng     DECIMAL(10, 7),
  subtotal         INT          NOT NULL,           -- so'm
  delivery_fee     INT          NOT NULL DEFAULT 0,
  discount         INT          NOT NULL DEFAULT 0,
  total            INT          NOT NULL,
  payment_method   VARCHAR(50),  -- 'payme' | 'click' | 'uzum' | 'naqd'
  payment_status   VARCHAR(20)  NOT NULL DEFAULT 'pending',
                   -- 'pending' | 'paid' | 'refunded'
  coupon_code      VARCHAR(50),
  coupon_id        UUID         REFERENCES coupons(id),
  notes            TEXT,
  estimated_delivery TIMESTAMPTZ,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_buyer_id   ON orders(buyer_id);
CREATE INDEX idx_orders_shop_id    ON orders(shop_id);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
```

---

### 2.9 `order_items`
```sql
CREATE TABLE order_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   UUID REFERENCES products(id),
  product_name VARCHAR(200) NOT NULL,  -- snapshot (mahsulot o'chib ketsa ham qolsin)
  quantity     INT          NOT NULL,
  unit_price   INT          NOT NULL,  -- so'm, buyurtma vaqtidagi narx (snapshot)
  total_price  INT          NOT NULL,  -- quantity * unit_price
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

---

### 2.10 `cart_items`
```sql
CREATE TABLE cart_items (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity   INT  NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
```

---

### 2.11 `addresses`
```sql
CREATE TABLE addresses (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label      VARCHAR(50)  NOT NULL,  -- 'Uy' | 'Ish' | 'Boshqa'
  street     VARCHAR(200) NOT NULL,
  building   VARCHAR(20)  NOT NULL,
  apartment  VARCHAR(20),
  floor      VARCHAR(10),
  entrance   VARCHAR(10),
  comment    TEXT,
  is_default BOOLEAN      NOT NULL DEFAULT false,
  latitude   DECIMAL(10, 7),
  longitude  DECIMAL(10, 7),
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);
```

---

### 2.12 `favorites`
```sql
CREATE TABLE favorites (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE INDEX idx_favorites_user_id    ON favorites(user_id);
CREATE INDEX idx_favorites_product_id ON favorites(product_id);
```

---

### 2.13 `notifications`
```sql
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      VARCHAR(200) NOT NULL,
  message    TEXT         NOT NULL,
  type       VARCHAR(20)  NOT NULL,  -- 'order' | 'promo' | 'system'
  is_read    BOOLEAN      NOT NULL DEFAULT false,
  payload    JSONB,                  -- qo'shimcha ma'lumotlar (order_id, etc.)
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id   ON notifications(user_id);
CREATE INDEX idx_notifications_is_read   ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

---

### 2.14 `chat_conversations`
```sql
CREATE TABLE chat_conversations (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID REFERENCES orders(id),
  buyer_id     UUID NOT NULL REFERENCES users(id),
  shop_id      UUID REFERENCES shops(id),
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_conversations_buyer_id ON chat_conversations(buyer_id);
CREATE INDEX idx_chat_conversations_shop_id  ON chat_conversations(shop_id);
```

---

### 2.15 `chat_messages`
```sql
CREATE TABLE chat_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
  sender_id       UUID NOT NULL REFERENCES users(id),
  text            TEXT NOT NULL,
  is_read         BOOLEAN     NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_created_at      ON chat_messages(created_at);
```

---

### 2.16 `deliveries`
```sql
CREATE TABLE deliveries (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID NOT NULL REFERENCES orders(id),
  courier_id  UUID REFERENCES users(id),
  status      VARCHAR(20) NOT NULL DEFAULT 'available',
               -- 'available' | 'accepted' | 'picked_up' | 'delivered' | 'cancelled'
  pickup_lat  DECIMAL(10, 7),
  pickup_lng  DECIMAL(10, 7),
  delivery_lat DECIMAL(10, 7),
  delivery_lng DECIMAL(10, 7),
  distance_km DECIMAL(6, 2),
  accepted_at  TIMESTAMPTZ,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deliveries_order_id   ON deliveries(order_id);
CREATE INDEX idx_deliveries_courier_id ON deliveries(courier_id);
CREATE INDEX idx_deliveries_status     ON deliveries(status);
```

---

### 2.17 `earnings` (kuryer daromadi)
```sql
CREATE TABLE earnings (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courier_id   UUID NOT NULL REFERENCES users(id),
  delivery_id  UUID REFERENCES deliveries(id),
  amount       INT  NOT NULL,   -- so'm
  type         VARCHAR(20) NOT NULL DEFAULT 'delivery',
               -- 'delivery' | 'bonus' | 'withdrawal'
  description  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_earnings_courier_id ON earnings(courier_id);
CREATE INDEX idx_earnings_created_at ON earnings(created_at DESC);
```

---

### 2.18 `coupons`
```sql
CREATE TABLE coupons (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code             VARCHAR(50)  NOT NULL UNIQUE,
  discount_percent INT,
  discount_amount  INT,         -- so'm (fixed amount)
  min_order_amount INT,
  max_uses         INT,
  used_count       INT          NOT NULL DEFAULT 0,
  expires_at       TIMESTAMPTZ,
  is_active        BOOLEAN      NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coupons_code ON coupons(code);
```

---

### 2.19 `transactions` (to'lov tarixi)
```sql
CREATE TABLE transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        UUID REFERENCES orders(id),
  user_id         UUID NOT NULL REFERENCES users(id),
  amount          INT  NOT NULL,
  type            VARCHAR(20) NOT NULL,
               -- 'payment' | 'refund' | 'withdrawal'
  payment_method  VARCHAR(50),  -- 'payme' | 'click' | 'uzum' | 'naqd'
  external_id     VARCHAR(200), -- to'lov tizimidan qaytgan ID
  status          VARCHAR(20)  NOT NULL DEFAULT 'pending',
               -- 'pending' | 'completed' | 'failed' | 'refunded'
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_user_id    ON transactions(user_id);
CREATE INDEX idx_transactions_order_id   ON transactions(order_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
```

---

### 2.20 `inventory_items` (ta'minotchi uchun)
```sql
CREATE TABLE inventory_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id  UUID         NOT NULL REFERENCES users(id),
  shop_id      UUID         NOT NULL REFERENCES shops(id),
  name         VARCHAR(200) NOT NULL,  -- "Un (premium)", "Yog'"
  unit         VARCHAR(20)  NOT NULL,  -- 'kg' | 'dona' | 'litr' | 'qop'
  price_per_unit INT        NOT NULL,  -- so'm
  stock_qty    INT          NOT NULL DEFAULT 0,
  min_order_qty INT         NOT NULL DEFAULT 1,
  description  TEXT,
  image_url    TEXT,
  is_available BOOLEAN      NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_inventory_supplier_id ON inventory_items(supplier_id);
CREATE INDEX idx_inventory_shop_id     ON inventory_items(shop_id);
```

---

### 2.21 `promo_banners`
```sql
CREATE TABLE promo_banners (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title        VARCHAR(200) NOT NULL,
  subtitle     TEXT,
  discount_text VARCHAR(50),         -- "-20%"
  image_url    TEXT,
  color_start  VARCHAR(10),          -- hex: "#FA6400"
  color_end    VARCHAR(10),          -- hex: "#FF8A50"
  link_type    VARCHAR(20),          -- 'shop' | 'product' | 'url'
  link_id      UUID,
  link_url     TEXT,
  is_active    BOOLEAN      NOT NULL DEFAULT true,
  sort_order   INT          NOT NULL DEFAULT 0,
  expires_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
```

---

## 3. API Endpoints (To'liq ro'yxat)

> `[auth]` = JWT token talab qilinadi  
> `[buyer]` = faqat buyer role  
> `[bakery]` = faqat bakery role  
> `[supplier]` = faqat supplier role  
> `[courier]` = faqat courier role

---

### 3.1 Auth

#### `POST /auth/send-otp`
Telefon raqamiga OTP kod yuboradi (SMS orqali).
```json
// Request
{
  "phone": "+998901234567"
}

// Response
{
  "success": true,
  "data": {
    "expires_in": 300  // seconds
  }
}
```
- Rate limit: 1 request / 60 soniya per telefon raqam
- Auth: yo'q

---

#### `POST /auth/verify-otp`
OTP kodni tekshiradi va foydalanuvchi mavjud bo'lsa token qaytaradi.
```json
// Request
{
  "phone": "+998901234567",
  "code": "1234"
}

// Response (foydalanuvchi mavjud)
{
  "success": true,
  "data": {
    "is_new_user": false,
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "user": {
      "id": "uuid",
      "name": "Jasur",
      "phone": "+998901234567",
      "role": "buyer",
      "avatar_url": null
    }
  }
}

// Response (yangi foydalanuvchi — register kerak)
{
  "success": true,
  "data": {
    "is_new_user": true,
    "otp_token": "temp_token_for_register"
  }
}
```
- Auth: yo'q

---

#### `POST /auth/register`
Yangi foydalanuvchi ro'yxatdan o'tadi. OTP tasdiqlangandan so'ng chaqiriladi.
```json
// Request
{
  "otp_token": "temp_token_for_register",
  "name": "Jasur Abdullayev",
  "role": "buyer"   // 'buyer' | 'bakery' | 'supplier' | 'courier'
}

// Response
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "user": { ... }
  }
}
```
- Auth: yo'q

---

#### `POST /auth/login`
Telefon + parol bilan kirish (eski flow, agar OTP ishlatilmasa).
```json
// Request
{
  "phone": "+998901234567",
  "password": "secret123",
  "role": "buyer"
}

// Response
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "user": { ... }
  }
}
```
- Auth: yo'q

---

#### `POST /auth/refresh`
Access tokenni yangilaydi.
```json
// Request
{
  "refresh_token": "eyJ..."
}

// Response
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ..."
  }
}
```
- Auth: yo'q (refresh token o'zi auth)

---

#### `POST /auth/logout`
Refresh tokenni bekor qiladi.
```json
// Request
{
  "refresh_token": "eyJ..."
}
```
- Auth: `[auth]`

---

#### `POST /auth/switch-role`
Foydalanuvchi rolini almashtiradi. Yangi role uchun token qaytaradi.
```json
// Request
{
  "role": "bakery"
}

// Response
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "user": { "role": "bakery", ... }
  }
}
```
- Auth: `[auth]`

---

### 3.2 Profile

#### `GET /profile`
Joriy foydalanuvchi ma'lumotlari.
```json
// Response
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Jasur Abdullayev",
    "phone": "+998901234567",
    "email": "jasur@email.com",
    "avatar_url": "https://...",
    "role": "buyer",
    "created_at": "2026-01-15T10:00:00Z"
  }
}
```
- Auth: `[auth]`

---

#### `PUT /profile`
Profil ma'lumotlarini yangilash.
```json
// Request
{
  "name": "Jasur Abdullayev",
  "email": "jasur@email.com"
}
```
- Auth: `[auth]`

---

#### `PUT /profile/avatar`
Profil rasmini yuklash. `multipart/form-data` format.
- Field: `avatar` (file)
- Response: `{ "data": { "avatar_url": "https://..." } }`
- Auth: `[auth]`

---

#### `PUT /profile/change-password`
Parolni o'zgartirish.
```json
// Request
{
  "current_password": "old_pass",
  "new_password": "new_pass"
}
```
- Auth: `[auth]`

---

### 3.3 Shops

#### `GET /shops`
Do'konlar ro'yxati.
```
Query params:
  - page: int (default: 1)
  - pageSize: int (default: 20)
  - type: 'bakery' | 'supplier'
  - district: string
  - lat: float (foydalanuvchi joylashuvi)
  - lng: float
  - radius_km: float (default: 10)
  - status: 'active' (default: active)
```
```json
// Response
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Patirchi Markaziy",
      "owner_name": "Abdullayev Jasur",
      "logo_url": null,
      "is_open": true,
      "open_time": "08:00",
      "close_time": "22:00",
      "address": "Toshkent sh., Chilonzor...",
      "district": "Chilonzor",
      "latitude": 41.2856,
      "longitude": 69.2044,
      "rating": 4.8,
      "shop_type": "bakery",
      "status": "active",
      "distance_km": 1.2   // agar lat/lng berilgan bo'lsa
    }
  ],
  "meta": { "total": 50, "page": 1, "pageSize": 20, "hasMore": true }
}
```
- Auth: yo'q

---

#### `GET /shops/:id`
Bitta do'kon to'liq ma'lumoti.
- Auth: yo'q

---

#### `GET /shops/:id/products`
Do'kon mahsulotlari ro'yxati.
```
Query params:
  - page, pageSize
  - category_id: uuid
  - is_available: bool
```
- Auth: yo'q

---

#### `POST /shops` `[auth]`
Yangi do'kon yaratish (bakery / supplier).
```json
// Request
{
  "name": "Mening Nonvoyxonam",
  "shop_type": "bakery",
  "address": "...",
  "district": "Chilonzor",
  "latitude": 41.29,
  "longitude": 69.20,
  "open_time": "08:00",
  "close_time": "22:00",
  "description": "..."
}
```
- Status default: `pending` (admin tasdiqlashi kerak)

---

#### `PUT /shops/:id` `[auth]` `[bakery|supplier]`
Do'kon ma'lumotlarini yangilash.

---

### 3.4 Products

#### `GET /products`
```
Query params:
  - page, pageSize
  - shop_id: uuid
  - category_id: uuid
  - is_available: bool
  - min_price, max_price: int
```
- Auth: yo'q

---

#### `GET /products/:id`
- Auth: yo'q

---

#### `GET /products/search`
```
Query params:
  - q: string (search query)
  - shop_id, category_id, min_price, max_price
  - page, pageSize
```
- Auth: yo'q

---

#### `GET /products/categories`
Kategoriyalar ro'yxati.
```json
// Response
{
  "success": true,
  "data": [
    { "id": "uuid", "name": "Tandir non", "slug": "tandir-non", "sort_order": 1 }
  ]
}
```
- Auth: yo'q

---

#### `POST /bakery/products` `[auth]` `[bakery]`
Yangi mahsulot qo'shish.
```json
// Request
{
  "name": "Qoqon patir",
  "price": 5000,
  "old_price": 8000,
  "discount_percent": 38,
  "weight": 1,
  "weight_unit": "dona",
  "ingredients": ["un", "suv", "tuz", "yog'"],
  "description": "An'anaviy Qo'qon patiri...",
  "category_id": "uuid",
  "is_available": true
}
```

---

#### `PUT /bakery/products/:id` `[auth]` `[bakery]`
Mahsulotni yangilash.

---

#### `DELETE /bakery/products/:id` `[auth]` `[bakery]`
Mahsulotni o'chirish (soft delete: `is_available = false`).

---

### 3.5 Buyer — Favorites (Sevimlilar)

#### `GET /buyer/favorites` `[auth]` `[buyer]`
Sevimli mahsulotlar ro'yxati.

---

#### `POST /buyer/favorites/:productId` `[auth]` `[buyer]`
Sevimlilar ro'yxatiga qo'shish.

---

#### `DELETE /buyer/favorites/:productId` `[auth]` `[buyer]`
Sevimlilardan o'chirish.

---

### 3.6 Cart (Savatcha)

#### `GET /cart` `[auth]`
Joriy savatcha.
```json
// Response
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "product": {
          "id": "uuid",
          "name": "Qoqon patir",
          "price": 5000,
          "image_url": "...",
          "shop_id": "1",
          "shop_name": "Patirchi Markaziy",
          "is_available": true
        },
        "quantity": 2,
        "total_price": 10000
      }
    ],
    "subtotal": 10000,
    "delivery_fee": 15000,
    "discount": 0,
    "total": 25000,
    "coupon_code": null,
    "delivery_method": "courier"
  }
}
```

---

#### `POST /cart/items` `[auth]`
Savatchaga mahsulot qo'shish.
```json
{
  "product_id": "uuid",
  "quantity": 2
}
```

---

#### `PUT /cart/items/:productId` `[auth]`
Miqdorni yangilash.
```json
{
  "quantity": 3
}
```

---

#### `DELETE /cart/items/:productId` `[auth]`
Savatchadan o'chirish.

---

#### `POST /cart/coupon` `[auth]`
Kupon kodi qo'llash.
```json
// Request
{
  "code": "FIRST20"
}

// Response
{
  "success": true,
  "data": {
    "discount_percent": 10,
    "discount_amount": 2500
  }
}
```

---

#### `POST /cart/checkout` `[auth]` `[buyer]`
Buyurtma berish.
```json
// Request
{
  "delivery_method": "courier",
  "address_id": "uuid",  // yoki delivery_address string
  "payment_method": "payme",
  "coupon_code": "FIRST20",
  "notes": "Qo'ng'iroq qilmang"
}

// Response
{
  "success": true,
  "data": {
    "order_id": "uuid",
    "order_number": "10234",
    "status": "pending",
    "total": 22500,
    "payment_url": "https://checkout.payme.uz/..."  // to'lov URL (agar online bo'lsa)
  }
}
```
- Savatchani tozalaydi checkout'dan so'ng

---

### 3.7 Orders (Buyurtmalar)

#### `GET /orders` `[auth]`
Buyurtmalar ro'yxati (buyer uchun — o'z buyurtmalari).
```
Query params:
  - status: 'active' | 'history' | 'pending' | 'delivering' | 'delivered' | 'cancelled'
  - page, pageSize
```

---

#### `GET /orders/:id` `[auth]`
Bitta buyurtma to'liq ma'lumoti.
```json
// Response
{
  "success": true,
  "data": {
    "id": "uuid",
    "order_number": "10234",
    "items": [
      {
        "product_name": "Patir non",
        "quantity": 3,
        "unit_price": 8000,
        "total_price": 24000
      }
    ],
    "status": "delivering",
    "shop": {
      "id": "1",
      "name": "Toshkent Non",
      "phone": "+998..."
    },
    "delivery_address": "Chilonzor ko'chasi, uy 12...",
    "payment_method": "Payme",
    "subtotal": 49000,
    "delivery_fee": 15000,
    "discount": 0,
    "total": 64000,
    "created_at": "2026-01-15T12:00:00Z",
    "estimated_delivery": "2026-01-15T12:30:00Z",
    "courier": {
      "name": "Bobur",
      "phone": "+998..."
    }
  }
}
```

---

#### `POST /orders/:id/cancel` `[auth]`
Buyurtmani bekor qilish (faqat `pending` statusda).
```json
{
  "reason": "Fikrimi o'zgartirdim"
}
```

---

#### `GET /orders/:id/track` `[auth]`
Buyurtmani real-vaqtda kuzatish (kuryer koordinatalari).
```json
// Response
{
  "success": true,
  "data": {
    "status": "delivering",
    "courier": {
      "name": "Bobur",
      "lat": 41.299,
      "lng": 69.241
    },
    "estimated_arrival_minutes": 15
  }
}
```

---

### 3.8 Addresses (Manzillar)

#### `GET /addresses` `[auth]`
Foydalanuvchi manzillari ro'yxati.

---

#### `POST /addresses` `[auth]`
Yangi manzil qo'shish.
```json
{
  "label": "Uy",
  "street": "Chilonzor ko'chasi",
  "building": "12",
  "apartment": "45",
  "floor": "4",
  "entrance": "2",
  "comment": "Qo'ng'iroq qiling",
  "is_default": true,
  "latitude": 41.2995,
  "longitude": 69.2401
}
```

---

#### `PUT /addresses/:id` `[auth]`
Manzilni yangilash.

---

#### `DELETE /addresses/:id` `[auth]`
Manzilni o'chirish.

---

#### `PUT /addresses/:id/default` `[auth]`
Manzilni asosiy qilib belgilash. (body kerak emas)

---

### 3.9 Notifications (Bildirishnomalar)

#### `GET /notifications` `[auth]`
```
Query params:
  - page, pageSize
  - type: 'order' | 'promo' | 'system'
  - is_read: bool
```

---

#### `PUT /notifications/:id/read` `[auth]`
O'qilgan deb belgilash.

---

#### `PUT /notifications/read-all` `[auth]`
Barcha bildirishnomalarni o'qilgan deb belgilash.

---

### 3.10 Chat

#### `GET /chats` `[auth]`
Suhbatlar ro'yxati.
```json
// Response
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "other_party": {
        "id": "uuid",
        "name": "Patirchi Markaziy",
        "avatar_url": null
      },
      "last_message": "Buyurtmangiz tayyorlanyapti",
      "last_message_at": "2026-01-15T12:05:00Z",
      "unread_count": 2
    }
  ]
}
```

---

#### `GET /chats/:id/messages` `[auth]`
```
Query params:
  - page, pageSize (cursor-based: before_id yoki before_timestamp)
```

---

#### `POST /chats/:id/messages` `[auth]`
Xabar yuborish.
```json
{
  "text": "Buyurtma qachon tayyor bo'ladi?"
}
```

---

### 3.11 Bakery (Nonvoyxona)

#### `GET /bakery/orders` `[auth]` `[bakery]`
Nonvoyxonaga kelgan buyurtmalar.
```
Query params:
  - status: 'pending' | 'confirmed' | 'preparing' | 'delivering' | 'delivered' | 'cancelled'
  - page, pageSize
  - date: YYYY-MM-DD
```

---

#### `PUT /bakery/orders/:id/status` `[auth]` `[bakery]`
Buyurtma holatini yangilash.
```json
{
  "status": "confirmed",  // yoki: preparing, delivering, delivered, cancelled
  "message": "30 daqiqada tayyor bo'ladi"  // optional, buyer'ga xabar
}
```

---

#### `GET /bakery/stats` `[auth]` `[bakery]`
Dashboard statistikasi.
```json
// Response
{
  "success": true,
  "data": {
    "today": {
      "orders_count": 24,
      "revenue": 520000,
      "pending_count": 5
    },
    "this_week": {
      "orders_count": 156,
      "revenue": 3240000
    },
    "this_month": {
      "orders_count": 540,
      "revenue": 11500000
    },
    "open_orders_total": 2501000,
    "paid_percent": 65,
    "chart": [
      { "date": "2026-01-09", "revenue": 450000, "orders": 18 },
      { "date": "2026-01-10", "revenue": 620000, "orders": 24 }
    ]
  }
}
```

---

#### `GET /bakery/products` `[auth]` `[bakery]`
Nonvoyxona o'z mahsulotlari ro'yxati.

---

### 3.12 Supplier (Ta'minotchi)

#### `GET /supplier/products` `[auth]` `[supplier]`
Ta'minotchi mahsulotlari (inventar).
```
Query params:
  - page, pageSize
  - is_available: bool
```

---

#### `POST /supplier/products` `[auth]` `[supplier]`
Yangi inventar mahsulot.
```json
{
  "name": "Un (premium)",
  "unit": "kg",
  "price_per_unit": 15000,
  "stock_qty": 500,
  "min_order_qty": 5,
  "description": "...",
  "is_available": true
}
```

---

#### `PUT /supplier/products/:id` `[auth]` `[supplier]`
Inventar yangilash.

---

#### `GET /supplier/requests` `[auth]` `[supplier]`
Ta'minotchiga kelgan so'rovlar (nonvoyxonalardan).
```
Query params:
  - status: 'pending' | 'accepted' | 'rejected'
  - page, pageSize
```

---

### 3.13 Courier (Kuryer)

#### `GET /courier/available` `[auth]` `[courier]`
Kuryer uchun tayyor buyurtmalar (yetkazish kerak).
```
Query params:
  - lat, lng (kuryer joylashuvi)
  - radius_km
```
```json
// Response
{
  "success": true,
  "data": [
    {
      "delivery_id": "uuid",
      "order_id": "uuid",
      "order_number": "10234",
      "pickup_address": "Patirchi Markaziy, Chilonzor...",
      "pickup_lat": 41.2856,
      "pickup_lng": 69.2044,
      "delivery_address": "Chilonzor ko'chasi, uy 12...",
      "delivery_lat": 41.2995,
      "delivery_lng": 69.2401,
      "distance_km": 2.3,
      "estimated_fee": 8000,
      "items_count": 3
    }
  ]
}
```

---

#### `POST /courier/deliveries/:id/accept` `[auth]` `[courier]`
Yetkazishni qabul qilish.

---

#### `PUT /courier/deliveries/:id/status` `[auth]` `[courier]`
Yetkazish holatini yangilash.
```json
{
  "status": "picked_up",  // yoki: delivered, cancelled
  "lat": 41.2856,
  "lng": 69.2044
}
```

---

#### `GET /courier/deliveries/active` `[auth]` `[courier]`
Kuryerning hozirgi aktiv yetkazishlari.

---

#### `GET /courier/deliveries` `[auth]` `[courier]`
Kuryer yetkazish tarixi.
```
Query params:
  - status, page, pageSize
  - date_from, date_to
```

---

#### `GET /courier/earnings` `[auth]` `[courier]`
Kuryer daromadlari.
```
Query params:
  - period: 'today' | 'week' | 'month'
```
```json
// Response
{
  "success": true,
  "data": {
    "balance": 125000,
    "today": 35000,
    "this_week": 189000,
    "this_month": 752000,
    "transactions": [
      {
        "id": "uuid",
        "amount": 8000,
        "type": "delivery",
        "description": "Buyurtma #10234 yetkazildi",
        "created_at": "2026-01-15T13:30:00Z"
      }
    ]
  }
}
```

---

### 3.14 Finance (Nonvoyxona moliyaviy ko'rsatkichlari)

#### `GET /bakery/finance/summary` `[auth]` `[bakery]`
```
Query params:
  - period: 'today' | 'week' | 'month' | 'custom'
  - date_from, date_to (custom uchun)
```
```json
// Response
{
  "success": true,
  "data": {
    "revenue": 5560500,
    "expenses": 4060000,
    "profit": 1500500,
    "investment": 15410000,
    "growth_percent": 2.11,
    "daily": [
      { "date": "2026-01-09", "revenue": 450000, "expenses": 320000 }
    ]
  }
}
```

---

#### `GET /bakery/finance/transactions` `[auth]` `[bakery]`
To'lovlar tarixi.
```
Query params:
  - page, pageSize
  - date_from, date_to
  - type: 'payment' | 'refund'
```

---

### 3.15 Promo Banners

#### `GET /banners` 
Aktiv promo banner'lar (home screen uchun).
- Auth: yo'q

---

## 4. WebSocket Events (Real-time)

WebSocket endpoint: `wss://api.patirchi.uz/ws`  
Auth: `?token=<access_token>` query param yoki `Authorization` header.

---

### 4.1 Buyurtma holati o'zgarganda (barcha aloqador tomonlar uchun)

**Event: `order_status_changed`**
```json
{
  "event": "order_status_changed",
  "data": {
    "order_id": "uuid",
    "order_number": "10234",
    "status": "preparing",
    "message": "30 daqiqada tayyor bo'ladi",
    "updated_at": "2026-01-15T12:05:00Z"
  }
}
```
- Yuboriladi: buyer, bakery, courier (aloqador)

---

### 4.2 Yangi buyurtma (bakery uchun)

**Event: `new_order`**
```json
{
  "event": "new_order",
  "data": {
    "order_id": "uuid",
    "order_number": "10234",
    "buyer_name": "Jasur",
    "items_count": 3,
    "total": 64000,
    "delivery_method": "courier"
  }
}
```
- Yuboriladi: tegishli bakery

---

### 4.3 Yangi xabar (chat)

**Event: `new_chat_message`**
```json
{
  "event": "new_chat_message",
  "data": {
    "conversation_id": "uuid",
    "message_id": "uuid",
    "sender_id": "uuid",
    "sender_name": "Jasur",
    "text": "Buyurtma qachon tayyor?",
    "created_at": "2026-01-15T12:10:00Z"
  }
}
```

---

### 4.4 Kuryer joylashuvi yangilandi

**Event: `courier_location_updated`**
```json
{
  "event": "courier_location_updated",
  "data": {
    "order_id": "uuid",
    "delivery_id": "uuid",
    "lat": 41.2900,
    "lng": 69.2500,
    "estimated_arrival_minutes": 12
  }
}
```
- Yuboriladi: faqat tegishli buyer

---

### 4.5 Yangi yetkazish mavjud (kuryer uchun)

**Event: `delivery_available`**
```json
{
  "event": "delivery_available",
  "data": {
    "delivery_id": "uuid",
    "pickup_address": "...",
    "distance_km": 1.5,
    "estimated_fee": 8000
  }
}
```
- Yuboriladi: hududdagi barcha courier'lar

---

## 5. Third-party Integrations

### 5.1 To'lov tizimlari

**Payme** (`https://checkout.payme.uz`)
- Merchant ID va Secret key: Payme Business'dan olinadi
- API: `https://checkout.payme.uz/api`
- Webhook endpoint backend'da: `POST /webhooks/payme`
- Docs: `https://developer.payme.uz`

**Click** (`https://my.click.uz`)
- Merchant ID va Service ID: Click Business'dan
- Webhook: `POST /webhooks/click`
- Docs: `https://docs.click.uz`

**Uzum (Apelsin)** (`https://uzum.uz`)
- API integration hujjatlarni Uzum Business'dan olish kerak
- Webhook: `POST /webhooks/uzum`

To'lov oqimi:
1. Frontend: `POST /cart/checkout` → backend `payment_url` qaytaradi
2. Foydalanuvchi to'lov URL'ga o'tadi
3. To'lov tizimi webhook chaqiradi → backend order statusini `paid` qiladi
4. WebSocket orqali frontend'ga xabar yuboriladi

---

### 5.2 Yandex MapKit
- Mobile app ichida allaqachon `yandex_mapkit: ^4.0.0` integratsiyalangan
- Backend uchun geocoding kerak bo'lsa: Yandex Geocoder API
  - `https://geocode-maps.yandex.ru/1.x/?apikey=KEY&geocode=ADDRESS&format=json`
- API key: Yandex Developer Console'dan olish kerak

---

### 5.3 Firebase Cloud Messaging (Push Notifications)
- FCM Admin SDK (Node.js / Java / Python)
- FCM token mobile appdan `POST /profile` endpoint'i orqali backendga yuboriladi
- Backend push yuborishi:
```json
{
  "to": "fcm_token",
  "notification": {
    "title": "Buyurtmangiz tasdiqlandi",
    "body": "Buyurtma #10234 tayyorlanmoqda"
  },
  "data": {
    "type": "order",
    "order_id": "uuid"
  }
}
```
- Hujjat: `https://firebase.google.com/docs/cloud-messaging`

---

### 5.4 SMS (OTP)

O'zbekistonda mavjud SMS provayderlar:
- **Eskiz.uz** — `https://notify.eskiz.uz/api` (tavsiya etiladi)
- **Playmobile** — `https://playmobile.uz`
- **Ucell SMS API**

OTP logikasi:
- 4 xonali random kod generate qilinadi (`AppConstants.otpLength = 4`)
- `otp_codes` jadvalida saqlanadi, 5 daqiqa amal qiladi
- Rate limit: 1 ta SMS / 60 soniya per raqam
- 5 noto'g'ri urinishdan so'ng bloklash (15 daqiqa)

---

### 5.5 File Storage (Rasmlar)

**Tavsiya:** AWS S3 yoki **MinIO** (self-hosted, Uzbekistan uchun yaxshi)

MinIO konfiguratsiyasi:
- Endpoint: `s3.patirchi.uz` (o'z serverda)
- Bucket'lar: `avatars`, `products`, `shops`, `banners`
- CDN yoki signed URL orqali serve qilish
- Max file size: 5MB (rasm), format: JPEG/PNG/WebP

---

### 5.6 Geocoding (Manzil → Koordinata)
- Yandex Geocoder API yoki Nominatim (open-source)
- Foydalanuvchi manzilini `lat/lng`ga aylantirish uchun

---

## 6. Environment Variables

```env
# Server
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/patirchi_db
DB_POOL_MIN=2
DB_POOL_MAX=10

# JWT
JWT_ACCESS_SECRET=your_super_secret_access_key_min_32_chars
JWT_REFRESH_SECRET=your_super_secret_refresh_key_min_32_chars
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d

# SMS Provider (Eskiz)
SMS_EMAIL=your@email.com
SMS_PASSWORD=eskiz_password

# Firebase
FIREBASE_PROJECT_ID=patirchi-app
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@patirchi-app.iam.gserviceaccount.com

# Payme
PAYME_MERCHANT_ID=your_merchant_id
PAYME_SECRET_KEY=your_secret_key
PAYME_ENDPOINT=https://checkout.payme.uz/api

# Click
CLICK_MERCHANT_ID=your_merchant_id
CLICK_SERVICE_ID=your_service_id
CLICK_SECRET_KEY=your_secret_key

# Uzum
UZUM_MERCHANT_ID=your_merchant_id
UZUM_SECRET_KEY=your_secret_key

# File Storage (MinIO / S3)
S3_ENDPOINT=https://s3.patirchi.uz
S3_ACCESS_KEY=your_access_key
S3_SECRET_KEY=your_secret_key
S3_BUCKET_NAME=patirchi
S3_REGION=us-east-1

# Yandex MapKit / Geocoder
YANDEX_API_KEY=your_yandex_api_key

# WebSocket
WS_PORT=3001

# Rate Limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100
OTP_RATE_LIMIT_WINDOW_MS=60000
OTP_RATE_LIMIT_MAX=1

# Delivery
COURIER_FEE_BASE=15000  # so'm — mobile appdagi qiymat

# CORS
ALLOWED_ORIGINS=https://patirchi.uz,https://admin.patirchi.uz
```

---

## 7. Seed Data (Mock Data → Backend)

Mobile appdagi barcha mock data backendga seed sifatida yuklanishi kerak.

### 7.1 Categories (seed)
```json
[
  { "name": "Nonushta",    "slug": "nonushta",    "sort_order": 1 },
  { "name": "Tandir non",  "slug": "tandir-non",  "sort_order": 2 },
  { "name": "Patir",       "slug": "patir",       "sort_order": 3 },
  { "name": "Somsa",       "slug": "somsa",       "sort_order": 4 },
  { "name": "Shirin",      "slug": "shirin",      "sort_order": 5 },
  { "name": "Lavash",      "slug": "lavash",      "sort_order": 6 }
]
```

### 7.2 Shops (seed) — 6 ta nonvoyxona Toshkentda
```json
[
  {
    "name": "Patirchi Markaziy",
    "owner_name": "Abdullayev Jasur",
    "district": "Chilonzor",
    "address": "Toshkent sh., Chilonzor tumani, Muqimiy ko'chasi 44-uy",
    "latitude": 41.2856,
    "longitude": 69.2044,
    "open_time": "08:00",
    "close_time": "22:00",
    "rating": 4.8,
    "shop_type": "bakery",
    "status": "active"
  },
  {
    "name": "Oq Oltin Nonvoyxonasi",
    "owner_name": "Karimov Sanjar",
    "district": "Yunusobod",
    "address": "Toshkent sh., Yunusobod tumani, 12-kv",
    "latitude": 41.3407,
    "longitude": 69.2861,
    "open_time": "07:00",
    "close_time": "21:00",
    "rating": 4.6,
    "shop_type": "bakery",
    "status": "active"
  },
  {
    "name": "Samarqand Patir",
    "owner_name": "Rahimov Bobur",
    "district": "Shayhontohur",
    "address": "Toshkent sh., Shayhontohur tumani, Navoiy ko'chasi 15",
    "latitude": 41.3185,
    "longitude": 69.2520,
    "open_time": "06:00",
    "close_time": "20:00",
    "rating": 4.9,
    "shop_type": "bakery",
    "status": "active"
  },
  {
    "name": "Non Olami",
    "owner_name": "Toshmatov Ulug'bek",
    "district": "Mirzo Ulug'bek",
    "address": "Toshkent sh., Mirzo Ulug'bek tumani",
    "latitude": 41.3375,
    "longitude": 69.3050,
    "open_time": "07:30",
    "close_time": "22:30",
    "rating": 4.4,
    "shop_type": "bakery",
    "status": "active"
  },
  {
    "name": "Mazzali non",
    "owner_name": "Tursunov Baxtiyor",
    "district": "Olmazor",
    "address": "Turan, 6/10, Zarkaynar Street",
    "latitude": 41.3125,
    "longitude": 69.2452,
    "open_time": "07:00",
    "close_time": "16:00",
    "rating": 4.7,
    "shop_type": "bakery",
    "status": "active"
  },
  {
    "name": "Toshkent Patiri",
    "owner_name": "Aliyev Nodir",
    "district": "Yakkasaroy",
    "address": "Toshkent sh., Yakkasaroy tumani, Shota Rustaveli 12",
    "latitude": 41.2975,
    "longitude": 69.2780,
    "open_time": "06:30",
    "close_time": "21:00",
    "rating": 4.5,
    "shop_type": "bakery",
    "status": "active"
  }
]
```

### 7.3 Products (seed) — 12 ta mahsulot
```json
[
  { "name": "Qoqon patir",   "price": 5000, "old_price": 8000,  "discount_percent": 38, "weight": 1,   "weight_unit": "dona", "shop_name": "Patirchi Markaziy",   "ingredients": ["un", "suv", "tuz", "yog'"] },
  { "name": "Tandir non",    "price": 3000, "old_price": 4500,  "discount_percent": 33, "weight": 400, "weight_unit": "g",    "shop_name": "Patirchi Markaziy",   "ingredients": ["un", "suv", "tuz", "sedana"] },
  { "name": "Go'shtli somsa","price": 8000, "old_price": 12000, "discount_percent": 33, "weight": 200, "weight_unit": "g",    "shop_name": "Oq Oltin Nonvoyxonasi","ingredients": ["un", "go'sht", "piyoz", "tuz", "zira"] },
  { "name": "Obi non",       "price": 2500,                                              "weight": 350, "weight_unit": "g",    "shop_name": "Oq Oltin Nonvoyxonasi","ingredients": ["un", "suv", "tuz"] },
  { "name": "Samarqand noni","price": 6000, "old_price": 9000,  "discount_percent": 33, "weight": 500, "weight_unit": "g",    "shop_name": "Samarqand Patir",      "ingredients": ["un", "suv", "tuz", "sedana", "yog'"] },
  { "name": "Katlama",       "price": 7000,                                              "weight": 300, "weight_unit": "g",    "shop_name": "Patirchi Markaziy",   "ingredients": ["un", "yog'", "tuz"] },
  { "name": "Yupqa non",     "price": 2000, "old_price": 3500,  "discount_percent": 43, "weight": 150, "weight_unit": "g",    "shop_name": "Non Olami",            "ingredients": ["un", "suv", "tuz"] },
  { "name": "Chalpak",       "price": 4000,                                              "weight": 250, "weight_unit": "g",    "shop_name": "Non Olami",            "ingredients": ["un", "yog'", "shakar", "tuxum"] },
  { "name": "Yog'li patir",  "price": 5000,                                              "weight": 450, "weight_unit": "g",    "shop_name": "Mazzali non",          "ingredients": ["un", "yog'", "tuz", "suv"] },
  { "name": "Kulcha non",    "price": 3500,                                              "weight": 300, "weight_unit": "g",    "shop_name": "Mazzali non",          "ingredients": ["un", "suv", "tuz", "sedana"] },
  { "name": "Non lepyoshka", "price": 4500,                                              "weight": 400, "weight_unit": "g",    "shop_name": "Toshkent Patiri",      "ingredients": ["un", "suv", "tuz", "piyoz"] },
  { "name": "Shirmon non",   "price": 6000, "old_price": 8000,  "discount_percent": 25, "weight": 500, "weight_unit": "g",    "shop_name": "Toshkent Patiri",      "ingredients": ["un", "yog'", "suv", "tuz"] }
]
```

### 7.4 Coupons (seed)
```json
[
  {
    "code": "FIRST20",
    "discount_percent": 20,
    "min_order_amount": 10000,
    "max_uses": 1000,
    "description": "Birinchi buyurtmaga 20% chegirma"
  },
  {
    "code": "PATIRCHI15",
    "discount_percent": 15,
    "min_order_amount": 20000,
    "max_uses": 500
  }
]
```

### 7.5 Promo Banners (seed)
```json
[
  {
    "title": "PATIRCHI AKSIYASI",
    "subtitle": "Birinchi buyurtmangizga",
    "discount_text": "-20%",
    "color_start": "#FA6400",
    "color_end": "#FF8A50",
    "sort_order": 1,
    "is_active": true
  },
  {
    "title": "YANGI NONVOYXONA",
    "subtitle": "Samarqand Patir ochildi!",
    "discount_text": "-15%",
    "color_start": "#E91E63",
    "color_end": "#FF5252",
    "sort_order": 2,
    "is_active": true
  }
]
```

---

## 8. Qo'shimcha Eslatmalar

### 8.1 Do'kon ochiq/yopiq holati
`is_open` field ikkita yo'l bilan boshqarilishi mumkin:
1. **Avtomatik**: `open_time` va `close_time` asosida, har daqiqada cron job
2. **Manual**: Do'kon egasi toggle qiladi (soddaroq, tavsiya etiladi)

### 8.2 Rating hisoblash
- Buyurtma `delivered` statusiga o'tganda foydalanuvchi baholash imkoniyati
- `shops.rating` = weighted average, `rating_count` bilan birga yangilanadi

### 8.3 Delivery fee
Mobile appdagi qiymat: **15,000 so'm** (courier uchun), `pickup` uchun 0.
Backend'da konfiguratsiya sifatida saqlash tavsiya etiladi (dinamik o'zgartirish uchun).

### 8.4 Order number format
`order_number` — `BIGSERIAL` — auto-increment integer. Frontend'da `#10234` kabi ko'rsatiladi.

### 8.5 Soft delete
Mahsulotlar va do'konlar o'chirilib yuborilmaydi — `is_available = false` yoki `status = 'inactive'` qo'yiladi. Buyurtma tarixi to'liq saqlanib qoladi.

### 8.6 Telefon raqam format
`+998XXXXXXXXX` — 13 belgi. Mobile appdagi `phonePrefix = '+998'`, `phoneLength = 9`.

### 8.7 Admin Panel
Bu hujjatda admin panel endpointlari ko'rsatilmagan. Quyidagi admin funksiyalar kerak bo'ladi:
- Do'konlarni tasdiqlash / bloklash
- Kategoriyalarni boshqarish
- Foydalanuvchilarni boshqarish
- Promo banner'larni boshqarish
- Hisobotlar va statistika
