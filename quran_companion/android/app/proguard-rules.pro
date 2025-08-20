# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}

# SQLite
-keep class io.flutter.plugins.sqflite.** { *; }
-keep class com.tekartik.sqflite.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Kotlin
-dontwarn kotlin.**
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}