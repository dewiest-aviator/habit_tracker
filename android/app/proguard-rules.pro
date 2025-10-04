# Keep Flutter and Dart entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }

# Keep classes referenced via reflection by Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep providers referenced from AndroidManifest
-keep class androidx.core.content.FileProvider { *; }

# Retain kotlin metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Don't shrink the generated BuildConfig constants
-keep class **.BuildConfig { *; }
