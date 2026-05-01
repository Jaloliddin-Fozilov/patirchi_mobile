# ============================================================================
# Patirchi ProGuard / R8 Rules
# ============================================================================
# Default `proguard-android-optimize.txt` ga qo'shimcha keep rule'lar.
# isMinifyEnabled=true bo'lganda release build'da ishlatiladi.

# ----------------------------------------------------------------------------
# Flutter — embedding va plugin'lar (default rule'lar Flutter Gradle plugin'da)
# ----------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ----------------------------------------------------------------------------
# Yandex MapKit — reflection orqali yuklanadigan ichki sinflar
# ----------------------------------------------------------------------------
-keep class com.yandex.runtime.** { *; }
-keep class com.yandex.mapkit.** { *; }
-keep interface com.yandex.runtime.** { *; }
-keep interface com.yandex.mapkit.** { *; }
-dontwarn com.yandex.mapkit.**
-dontwarn com.yandex.runtime.**

# ----------------------------------------------------------------------------
# Kotlin metadata — reflection ishlatuvchi sinflar uchun
# ----------------------------------------------------------------------------
-keep class kotlin.Metadata { *; }
-keepattributes Signature
-keepattributes RuntimeVisibleAnnotations
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ----------------------------------------------------------------------------
# Native methods (JNI bridge)
# ----------------------------------------------------------------------------
-keepclasseswithmembernames class * {
    native <methods>;
}

# ----------------------------------------------------------------------------
# Parcelable & Serializable
# ----------------------------------------------------------------------------
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ----------------------------------------------------------------------------
# Crash xatoliklari uchun line number'lar saqlanadi
# ----------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
