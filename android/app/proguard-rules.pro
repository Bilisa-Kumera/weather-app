# Keep okhttp3 (used by http / Dio / Google Fonts)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Keep http package classes
-keep class io.flutter.plugins.http.** { *; }

# Keep Google Fonts internal classes (optional if you still want remote fonts)
-keep class com.google.fonts.** { *; }

# Keep your models if using JSON serialization / reflection
-keep class com.yourpackage.models.** { *; }

# Keep all generic annotations and signatures (already mostly done)
-keepattributes Signature, *Annotation*