# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keepattributes *Annotation*

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Kotlin serialization
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# JSON models (freezed/json_annotation)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
