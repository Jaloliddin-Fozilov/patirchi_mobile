import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ----------------------------------------------------------------------------
// Release signing — `android/key.properties` faylidan o'qiladi.
// CI muhitida fayl runtime'da yaratiladi (GitHub Secrets'dan).
// Lokal development uchun fayl mavjud bo'lmasa, debug keystore ishlatiladi.
// ----------------------------------------------------------------------------
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}

val hasReleaseSigning = keystoreProperties.containsKey("storeFile") &&
        keystoreProperties.containsKey("storePassword") &&
        keystoreProperties.containsKey("keyAlias") &&
        keystoreProperties.containsKey("keyPassword")

android {
    namespace = "com.patirchi.patirchi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Java 21 — Yandex MapKit 4.22.0+ talab qiladi (class file version 65)
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.patirchi.app"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Lokal `flutter run --release` ishlashi uchun fallback
                signingConfigs.getByName("debug")
            }
            // Code obfuscation va resource shrinking — release size kamaytiradi
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.yandex.android:maps.mobile:4.22.0-lite")
}

flutter {
    source = "../.."
}
