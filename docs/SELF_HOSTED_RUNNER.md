# Self-Hosted Runner + Telegram Delivery Setup

Patirchi build pipeline'ini **o'z serveringizda** ishga tushirish + APK'ni
**Telegram bot orqali yetkazib berish** uchun to'liq qo'llanma.

## 🎯 Qanday ishlaydi?

```
Push to mark branch
       │
       ▼
GitHub Actions trigger
       │
       ▼
┌──────────────────────┐
│ Self-hosted runner   │  (sizning serveringizda)
│ patirchi-builder     │
│                      │
│ • flutter build apk  │
│ • Sign with keystore │
└──────────┬───────────┘
           │
           ▼
   ┌─────────────────┐
   │  curl Telegram  │ ──────► @patirchibot ──────► Sizning chatga
   │  sendDocument   │
   └─────────────────┘
```

## 📋 Talablar

### Server (build uchun)
- **OS**: Ubuntu 22.04+ yoki Debian 12+
- **RAM**: 4 GB minimum (8 GB tavsiya)
- **Disk**: 30 GB bo'sh joy
- **Network**: GitHub.com va Google Storage'ga internet kirish
- **User**: yangi user (root emas — xavfsizlik)

### GitHub
- Repo'ga **admin access** (runner ro'yxatdan o'tkazish uchun)
- Secrets boshqarish huquqi

### Telegram
- Bot token (`@BotFather` orqali)
- Chat ID (admin chat yoki guruh)

---

## 🚀 1-bosqich: Server tayyorlash

### 1.1 Yangi user yarating
```bash
sudo adduser github-runner
sudo usermod -aG sudo github-runner
su - github-runner
```

### 1.2 Setup skriptni ishga tushiring
```bash
wget https://raw.githubusercontent.com/NozimjonDD/patirchi_mobile/mark/scripts/setup-runner.sh
chmod +x setup-runner.sh
./setup-runner.sh
```

Skript quyidagilarni avtomatik o'rnatadi:
- ✅ Java 17 (Temurin)
- ✅ Flutter SDK 3.27.1 (precached)
- ✅ Android SDK + cmdline-tools + build-tools 34/35 + NDK
- ✅ Environment vars (`~/.patirchi-ci-env`)
- ✅ GitHub Actions runner binary

**Vaqt**: ~10-15 daqiqa (700 MB Flutter + 1.5 GB Android SDK)

### 1.3 Tekshirish
```bash
source ~/.patirchi-ci-env
flutter --version       # 3.27.1
java -version           # 17.x
sdkmanager --list_installed
```

---

## 🔗 2-bosqich: Runner'ni GitHub'da ro'yxatdan o'tkazish

### 2.1 Token olish

GitHub'da:
1. https://github.com/NozimjonDD/patirchi_mobile/settings/actions/runners/new
2. **Linux** + **x64** (yoki ARM64 server uchun) tanlang
3. **Configure** bo'limidagi **token**'ni copy qiling (24 soat amal qiladi)

### 2.2 Serverda runner'ni configure qilish

```bash
cd ~/patirchi-ci/runner
./config.sh \
    --url https://github.com/NozimjonDD/patirchi_mobile \
    --token YOUR_TOKEN_HERE \
    --name patirchi-builder \
    --labels 'patirchi-builder,linux' \
    --work _work \
    --unattended
```

### 2.3 Systemd service sifatida ishga tushirish

```bash
sudo ~/patirchi-ci/runner/svc.sh install $USER
sudo ~/patirchi-ci/runner/svc.sh start
sudo ~/patirchi-ci/runner/svc.sh status
```

Endi runner avtomatik ishga tushadi va server reboot bo'lganda ham
qayta ulanadi.

### 2.4 Tekshirish
GitHub'da: https://github.com/NozimjonDD/patirchi_mobile/settings/actions/runners

Yashil **Idle** holatida ko'rinishi kerak.

---

## 🤖 3-bosqich: Telegram bot sozlash

### 3.1 Mavjud bot ishlatish

Sizda allaqachon `@patirchibot` bor. Token: backend `.env` faylida
(`TELEGRAM_BOT_TOKEN`). Build delivery uchun **shu bot'ni qayta
ishlatamiz** — yangisi shart emas.

### 3.2 Chat ID ni topish

Build APK qayerga yuboriladi? Sizda 3 ta variant:

#### Variant A: Shaxsiy chat (faqat siz olasiz)

1. Telegram'da `@patirchibot` ga `/start` yuboring
2. Quyidagi URL'ga kiring (TOKEN'ni o'zgartiring):
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
3. JSON javobida `"chat":{"id":123456789,...}` ko'rinishidagi son sizning chat ID
4. Misol: `123456789`

#### Variant B: Guruh chat (jamoa olishi uchun) — **tavsiya etiladi**

1. Telegram'da yangi guruh yarating ("Patirchi Builds" deb nomlang)
2. `@patirchibot` ni guruhga **admin** qilib qo'shing
3. Guruhda `/start@patirchibot` ni bosing
4. `getUpdates` URL'idan guruh chat ID ni oling
5. Guruh chat ID **manfiy son** bo'ladi: `-1001234567890`

#### Variant C: Channel (broadcast)

1. Yopiq channel yarating
2. `@patirchibot` ni admin qiling
3. Channel'dan biror xabar forward qiling `@JsonDumpBot`'ga
4. `forward_from_chat.id` qiymatini oling

### 3.3 Test qilish

```bash
curl -X POST \
  "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d chat_id="<CHAT_ID>" \
  -d text="🧪 Test xabar — Patirchi build pipeline"
```

Agar Telegram'da xabar kelsa — chat ID to'g'ri.

---

## 🔐 4-bosqich: GitHub Secrets

**Settings → Secrets and variables → Actions** bo'limiga 6 ta secret qo'shing:

| Secret | Tavsifi | Qiymat misol |
|--------|---------|--------------|
| `TELEGRAM_BOT_TOKEN` | Bot token | `7656543336:AAFlJg...` |
| `TELEGRAM_BUILD_CHAT_ID` | Chat / guruh ID | `-1001234567890` |
| `ANDROID_KEYSTORE_BASE64` | Keystore (base64) | `MIIKtAIBAzCCC...` |
| `ANDROID_KEYSTORE_PASSWORD` | Store password | `whh6nv...YZE` |
| `ANDROID_KEY_PASSWORD` | Key password | `whh6nv...YZE` |
| `ANDROID_KEY_ALIAS` | Alias nomi | `upload` |

**Eslatma:** Release build uchun barchasi kerak. Debug build uchun faqat
Telegram secrets kerak (signing yo'q).

---

## ✅ 5-bosqich: Test qilish

### 5.1 Manual trigger

1. GitHub: **Actions** tab
2. **Android Build** workflow
3. **Run workflow** tugmasi
4. Tanlang:
   - Branch: `mark`
   - Build type: `debug` yoki `release`
   - Send Telegram: `true`
5. **Run workflow**

### 5.2 Push trigger

```bash
cd patirchi
echo "// trigger build" >> lib/main.dart
git commit -am "ci: trigger build test"
git push origin mark
```

### 5.3 Tag trigger (release)

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 5.4 Kuzatish

GitHub Actions tab'da har bir job real-time log'lar bilan ko'rinadi.
Build tugagach Telegram'ga avtomatik yuboriladi:

```
🔨 Patirchi Debug Build
📦 Version: 1.0.0+1
🌿 Branch: mark
🔖 Commit: a1b2c3d
👤 By: NozimjonDD
📏 Size: 24M
💬 ci: trigger build test

[APK fayl]
```

---

## 🔧 Maintenance

### Runner'ni qayta ishga tushirish
```bash
sudo ~/patirchi-ci/runner/svc.sh stop
sudo ~/patirchi-ci/runner/svc.sh start
```

### Log ko'rish
```bash
sudo journalctl -u actions.runner.NozimjonDD-patirchi_mobile.patirchi-builder.service -f
```

### Disk tozalash
Build natijalari `~/patirchi-ci/runner/_work/` da saqlanadi. Vaqti-vaqti bilan:
```bash
du -sh ~/patirchi-ci/runner/_work/
# Agar 10 GB dan oshsa:
rm -rf ~/patirchi-ci/runner/_work/_temp
```

Workflow `Cleanup secrets` step'ida APK/AAB'larni o'chiradi, lekin Gradle
cache va boshqalar qoladi.

### Flutter version yangilash

Yangi Flutter version chiqarsa:
```bash
cd ~/patirchi-ci/flutter
git pull
flutter --version
```

Yoki to'liq qayta o'rnatish — `setup-runner.sh` ni qayta ishga tushiring.

### Runner'ni yangilash

```bash
sudo ~/patirchi-ci/runner/svc.sh stop
cd ~/patirchi-ci/runner
./config.sh remove --token YOUR_TOKEN
# Yangi runner yuklab oling (RUNNER_VERSION'ni o'zgartiring setup-runner.sh da)
./setup-runner.sh
# Qayta config qiling (yuqoridagi 2.2-2.3 qadamlar)
```

---

## 🛡️ Xavfsizlik

### Best practices

1. **Alohida user** — runner'ni `root` ostida ishga tushirmang
2. **Minimal sudo** — `github-runner` user'ga faqat package install
   uchun sudo bering
3. **Public repo'da fork-PR'lar** — workflow'da PR'lar GitHub-hosted
   runner'da ishlaydi (self-hosted'ga kirmaydi). Bu **arbitrary code
   execution** xavfini yo'q qiladi
4. **Secrets** — runner serverda `.env` faylda saqlanmaydi, faqat workflow
   runtime'da yuklanadi
5. **Cleanup** — har build oxirida `key.properties` va keystore o'chiriladi

### Firewall
Runner'ga inbound port kerak emas — u outbound HTTPS bilan GitHub'ga ulanadi.

```bash
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw enable
```

### Auto-update runner

`~/patirchi-ci/runner/.runner` faylida `auto_update_disabled: false`
qo'yilganligini tekshiring (default holat). GitHub har 1-2 oyda runner
binary yangilab turadi.

---

## 📊 Build vaqti taxminiy

Self-hosted runner cache bilan:

| Job | GitHub-hosted | Self-hosted |
|-----|---------------|-------------|
| analyze | 4-5 min (cold) / 1-2 min (warm) | **30-60 sec** |
| build-debug | 8-12 min | **3-5 min** |
| build-release | 12-18 min | **5-8 min** |

Self-hosted **3-4x tezroq** chunki Flutter SDK, Gradle, Android SDK
allaqachon serverda.

---

## 🐛 Troubleshooting

### Runner offline ko'rinadi
```bash
sudo systemctl status actions.runner.*
sudo journalctl -u actions.runner.* -n 50
```

### Build fail bo'ldi: "flutter: command not found"
Workflow runner sessiyasida `~/.bashrc` yuklanmaydi. Service'da PATH ni
qo'lda o'rnatish kerak:
```bash
# Edit /etc/systemd/system/actions.runner.*.service
# [Service] bo'limiga qo'shing:
Environment="PATH=/home/github-runner/patirchi-ci/flutter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64"
Environment="ANDROID_HOME=/home/github-runner/patirchi-ci/android-sdk"

# Reload va restart:
sudo systemctl daemon-reload
sudo systemctl restart actions.runner.*
```

### Telegram'ga yuborilmadi
GitHub Actions log'da xato qarang:
- "Bad Request: chat not found" → CHAT_ID noto'g'ri
- "Unauthorized" → BOT_TOKEN noto'g'ri yoki bot revoked
- "Request Entity Too Large" → APK 50MB dan katta (split per ABI ishlating)

### Build cache to'lib qoldi
```bash
df -h ~
~/patirchi-ci/flutter/bin/flutter clean   # global cache
rm -rf ~/.gradle/caches/build-cache-*     # Gradle build cache
rm -rf ~/.gradle/caches/transforms-*      # Gradle transforms
```

### Disk full
```bash
# Eng katta papkalarni topish:
du -sh ~/* ~/.* 2>/dev/null | sort -hr | head -20

# Odatdagi to'planuvchilar:
rm -rf ~/.gradle/caches/jars-*
rm -rf ~/.pub-cache/_temp
rm -rf ~/patirchi-ci/runner/_work/_temp
```

---

## 📚 Foydali havolalar

- [GitHub Actions self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Flutter Linux install](https://docs.flutter.dev/get-started/install/linux)
- [Telegram Bot API — sendDocument](https://core.telegram.org/bots/api#senddocument)
- [Android command-line tools](https://developer.android.com/tools)
