# Keep Firebase-related classes (if using Firebase)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.common.** { *; }
-keep class com.google.gson.** { *; }

# Keep Awesome Notifications plugin
-keep class me.carda.awesome_notifications.** { *; }
-keep class w4.b { *; }

# Flutter-related rules to prevent issues
-keep class io.flutter.** { *; }
-keep class com.example.** { *; }

# Keep attributes for annotations
-keepattributes *Annotation*

# Prevent stripping of JSON models
-keep class * implements android.os.Parcelable { *; }
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }

# Prevent obfuscation of method names
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent issues with reflection
-keepclassmembers class * {
    public <init>(...);
}

# Ensure Gson TypeToken is not removed
-keep class com.google.common.reflect.TypeToken
-keep class * extends com.google.common.reflect.TypeToken

# Keep WorkManager if used
-keep class androidx.work.** { *; }

# Prevent R8 from stripping Firebase DynamicLinks
-keep class com.google.firebase.dynamiclinks.** { *; }

# Keep all Parcelable implementations
-keep class * implements android.os.Parcelable { *; }

# Keep Retrofit, OkHttp (if used)
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
