# Manymail release (R8) rules.
#
# Only what the app's dependencies actually need. Flutter's own rules come from
# the plugin; these cover the libraries that use reflection or are entered from
# native code.

# --- WorkManager -------------------------------------------------------------
# Workers are instantiated reflectively by androidx.work, and the outbox worker
# is entered from a background process with no Dart reference to keep it alive.
-keep class androidx.work.** { *; }
-keep class dev.fluttercommunity.workmanager.** { *; }

# --- flutter_local / secure storage ------------------------------------------
# Tink (used by androidx.security) registers primitives by class name.
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# --- sqlite3 / drift ---------------------------------------------------------
# The native library is reached through JNI and must keep its names.
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# --- local_auth --------------------------------------------------------------
-keep class androidx.biometric.** { *; }

# --- Kotlin coroutines used by several plugins -------------------------------
-dontwarn kotlinx.coroutines.**

# Keep annotations that drive the above.
-keepattributes *Annotation*, InnerClasses, Signature, Exceptions

# R8 in full mode strips generic signatures that some JSON handling needs.
-keepattributes EnclosingMethod
