# Android CI/CD Setup

Patirchi mobile ilovasi uchun GitHub Actions orqali avtomatik build pipeline.

> **🔥 Yangi:** Build endi **bizning serverimizda** (self-hosted runner) ishlaydi
> va APK avtomatik **Telegram bot** orqali yuboriladi. To'liq setup uchun
> [SELF_HOSTED_RUNNER.md](SELF_HOSTED_RUNNER.md) ni o'qing.

## 📦 Workflow nima qiladi?

`.github/workflows/android.yml` — uchta job:

| Job | Qachon ishlaydi | Natija |
|-----|------------------|--------|
| **analyze** | Har push, PR, manual | `flutter analyze` + `flutter test` |
| **build-debug** | Push (mark/main/master/release/*), PR, manual=debug | Debug APK → artifact (14 kun) |
| **build-release** | Tag `v*.*.*`, manual=release | Release APK (split per ABI) + AAB → artifact (90 kun) + GitHub Release ga ilova |

## 🚀 Workflow trigger'lari

```yaml
on:
  push:
    branches: [mark, main, master, "release/**"]
    tags: ["v*.*.*"]
  pull_request:
    branches: [main, master, mark]
  workflow_dispatch:  # Actions tab'dan qo'lda ishga tushirish
```

### Misollar

- **Code'ni mark branch'iga push qilish** → analyze + debug APK build
- **PR ochish** → analyze + debug APK build (artifact PR'ga ilova qilinadi)
- **Tag yaratish** `git tag v1.0.0 && git push --tags` → release build + GitHub Release
- **Actions tab'dan "Run workflow"** → build_type: debug/release tanlash mumkin

## 🔐 GitHub Secrets sozlash

Release build uchun **4 ta secret** kerak. **Settings → Secrets and variables → Actions** bo'limida qo'shing.

### 1. Keystore yaratish (bir martalik)

Lokal mashinangizda:

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**Eslatma:** Parolni va alias'ni saqlab qo'ying — yo'qotsangiz Play Store'ga **boshqa hech qachon update push qila olmaysiz**.

### 2. Keystore'ni Base64'ga o'tkazish

**macOS / Linux:**
```bash
base64 -i upload-keystore.jks -o keystore.base64.txt
pbcopy < keystore.base64.txt   # macOS clipboard
# yoki: cat keystore.base64.txt | xclip -selection clipboard  # Linux
```

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```

### 3. GitHub Secrets ga 4 ta qiymat qo'shish

| Secret nomi | Qiymat |
|-------------|--------|
| `ANDROID_KEYSTORE_BASE64` | Yuqorida olingan base64 string |
| `ANDROID_KEYSTORE_PASSWORD` | `keytool` so'ragan keystore password |
| `ANDROID_KEY_PASSWORD` | `keytool` so'ragan key password (odatda keystore password bilan bir xil) |
| `ANDROID_KEY_ALIAS` | `upload` (yoki `keytool -alias` da bergan nomingiz) |

### 4. (Optional) Production environment

`build-release` job `environment: production` ishlatadi — bu **manual approval** talab qilishi mumkin (Settings → Environments → production → Required reviewers). Buni xohlamasangiz, workflow file'dan `environment:` qatorini olib tashlang.

## 📥 Build artifact'larni yuklash

### Debug APK

1. **Actions** tab → workflow run'ni tanlash
2. Pastda **Artifacts** bo'limi → `patirchi-debug-<sha>.zip`
3. Yuklab oling → APK ni telefonga o'rnating

### Release APK / AAB

- **Manual run** → Artifacts'da topiladi
- **Tag push** → **Releases** bo'limida avtomatik yangi release + APK + AAB ilova qilinadi

## 🏗️ Build configuration tafsilotlari

### `patirchi/android/app/build.gradle.kts`

```kotlin
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) load(FileInputStream(file))
}
val hasReleaseSigning = keystoreProperties.containsKey("storeFile") && /* ... */

signingConfigs {
    if (hasReleaseSigning) {
        create("release") { /* read from key.properties */ }
    }
}

buildTypes {
    release {
        signingConfig = if (hasReleaseSigning) {
            signingConfigs.getByName("release")
        } else {
            signingConfigs.getByName("debug")  // lokal dev fallback
        }
        isMinifyEnabled = true        // ProGuard/R8
        isShrinkResources = true      // Unused resources olib tashlanadi
    }
}
```

**Conditional pattern:** `key.properties` mavjud bo'lmasa (lokal dev), debug keystore'ga fallback qiladi. CI'da fayl runtime'da yaratiladi (Secrets'dan), shu sababli production signing ishlaydi.

### ProGuard/R8

`patirchi/android/app/proguard-rules.pro` — keep rule'lar:
- Flutter embedding + plugins
- Yandex MapKit (reflection)
- Kotlin metadata
- Native methods (JNI)
- Parcelable / Serializable

**Crash bo'lsa:** `proguard-rules.pro`'ga `-keep class your.package.** { *; }` qo'shing.

## 🧪 Lokal release build (CI'siz test qilish)

```bash
cd patirchi
cp android/key.properties.example android/key.properties
# key.properties ni edit qiling, real qiymatlarni kiriting
# upload-keystore.jks ni android/app/ ga ko'chiring

flutter build apk --release --split-per-abi
# yoki:
flutter build appbundle --release
```

**Eslatma:** Loyiha qoidasi — lokal build/run/test qilmaymiz. CI'da test qilamiz.

## 📊 Build vaqti taxminiy

| Job | Cache yo'q | Cache bilan |
|-----|------------|-------------|
| analyze | 4-5 min | 1-2 min |
| build-debug | 8-12 min | 4-6 min |
| build-release | 12-18 min | 6-10 min |

Cache: `~/.pub-cache`, `~/.gradle/caches`, Flutter SDK.

## 🔍 Workflow debug qilish

Build fail bo'lsa:

1. **Actions** tab → fail bo'lgan run → log'larni ochish
2. Eng odatiy muammolar:
   - **Java version** — `targetCompatibility = VERSION_17` lekin CI'da Java 11 → workflow'da `JAVA_VERSION: "17"` to'g'rimi tekshiring
   - **Flutter version** — `pubspec.yaml`'dagi `sdk: ^3.7.2` ga mos kelish kerak
   - **Keystore xatoligi** — secret nomi/qiymati noto'g'ri
   - **ProGuard crash** — `keep` rule yetishmaydi

## 🚦 Branch protection (tavsiya)

`main` branch uchun **Settings → Branches → Branch protection rules**:
- ✅ Require status checks to pass before merging
  - `Analyze + Test` (analyze job)
  - `Build Debug APK` (build-debug job)
- ✅ Require branches to be up to date

Bu — **rebase qilinmagan PR merge qilinishini bloklaydi** + tests fail bo'lsa merge ruxsat bermaydi.

## 📚 Qo'shimcha resurs'lar

- [Flutter Android signing](https://docs.flutter.dev/deployment/android#signing-the-app)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [subosito/flutter-action](https://github.com/subosito/flutter-action) — Flutter setup action
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release) — Release attachment action
