import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is opt-in: drop a `key.properties` next to this module's
// parent (android/key.properties) and the release build picks it up with no
// code change. Without it, release builds are UNSIGNED.
//
// Unsigned, not debug-signed, because that is what F-Droid requires: its build
// server has no key.properties, and the `output` of an F-Droid recipe must be
// an unsigned APK that F-Droid then signs itself. The same unsigned build is
// what a reproducible-build check compares against. For a quick local install
// without a keystore, use `flutter run` or `flutter build apk --debug`.
//
// MANYMAIL_UNSIGNED=true forces an unsigned build even when key.properties is
// present, so you can produce exactly what F-Droid produces and diff the two.
//
// android/key.properties (gitignored):
//   storeFile=D:/path/to/manymail-upload.jks   <- forward slashes, see below
//   storePassword=...
//   keyAlias=manymail
//   keyPassword=...                            <- optional if the same
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
// A .properties file treats a backslash as an escape character, so a Windows
// path written as D:\Coding\ManyMail\x.jks loads as D:CodingManyMailx.jks with
// no error at all. That then resolved relative to this module and failed deep
// inside signReleaseBundle with a baffling message. Normalise the separators,
// and resolve anything relative against the repository root rather than app/.
fun resolveKeystore(raw: String): File {
    val path = raw.trim().replace('\\', '/')
    val file = File(path)
    return if (file.isAbsolute) file else rootProject.file("../$path")
}

val storeFileProperty: String? = keystoreProperties.getProperty("storeFile")
val releaseKeystore: File? = storeFileProperty
    ?.takeIf { it.isNotBlank() }
    ?.let { resolveKeystore(it) }
val hasReleaseKeystore = releaseKeystore?.exists() == true
val forceUnsigned = System.getenv("MANYMAIL_UNSIGNED")?.lowercase() == "true"
val signRelease = hasReleaseKeystore && !forceUnsigned

// Naming a keystore that is not there is always a mistake worth stopping for.
// Falling through to the debug key would produce something that looks like a
// release build and that Play rejects on upload.
if (storeFileProperty != null && !hasReleaseKeystore) {
    throw GradleException(
        "Manymail: android/key.properties points at a keystore that does not exist.\n" +
            "  storeFile = $storeFileProperty\n" +
            "  resolved  = ${releaseKeystore?.absolutePath}\n" +
            "Use forward slashes: storeFile=D:/path/to/manymail-upload.jks\n" +
            "A backslash is an escape character in a .properties file."
    )
}

android {
    namespace = "com.bunnypranav.manymail"
    // 37 because receive_sharing_intent compiles against it. Android 17 is
    // published as the platform package "android-37.0", but AGP turns a bare
    // `compileSdk = 37` into the lookup hash "android-37". Where the platform
    // was installed beforehand that still resolves; where Gradle installs it
    // mid-build, as on a fresh CI or F-Droid build server, the build fails with
    // "Failed to find target with hash string 'android-37'". The minor level
    // makes AGP ask for "android-37.0" and fixes it everywhere.
    compileSdk = 37
    compileSdkMinor = 0

    // ndkVersion is deliberately not set: Flutter's plugin supplies its own
    // (28.2.13676358 for Flutter 3.47.4), which is what compiles SQLite and the
    // jni library. Setting it here makes Gradle try to auto-install the NDK
    // through the deprecated sdkmanager shim, which crashes on current
    // cmdline-tools. Install it through Android Studio instead.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // By default AGP writes a list of the app's dependencies into the APK's
    // signing block, encrypted with a key only Google holds. It is an opaque
    // blob in every signed APK, F-Droid asks apps to turn it off, and it would
    // break a reproducible-build comparison against F-Droid's own build.
    //
    // The App Bundle keeps it: Play Console reads it to flag known-vulnerable
    // SDK versions, and it never reaches a device from there.
    dependenciesInfo {
        includeInApk = false
        includeInBundle = true
    }

    defaultConfig {
        applicationId = "com.bunnypranav.manymail"
        // flutter.minSdkVersion is 24, above this app's floor of 23
        // (flutter_secure_storage's Keystore backend and local_auth).
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = releaseKeystore
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                // A PKCS12 keystore cannot hold a separate key password, and
                // keytool's JKS prompt defaults to "same as keystore password",
                // so an absent keyPassword nearly always means "the same one"
                // rather than "no password".
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Left unset otherwise, which AGP builds as an unsigned APK.
            if (signRelease) {
                signingConfig = signingConfigs.getByName("release")
            }

            // Shrink and obfuscate. The rules file keeps the reflective bits
            // the plugins rely on.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// Say which one this is, so an unsigned build is never mistaken for a signed one.
if (!signRelease) {
    logger.lifecycle(
        if (forceUnsigned) {
            "Manymail: MANYMAIL_UNSIGNED=true — release builds are UNSIGNED."
        } else {
            "Manymail: android/key.properties not found — release builds are " +
                "UNSIGNED, as F-Droid requires. They will not install until signed."
        }
    )
}

// F-Droid publishes one APK per ABI, each with its own version code, and needs
// them ordered so that every build of a newer release outranks every build of
// an older one. Flutter's own scheme (abi * 1000 + versionCode) gets that
// backwards; it is switched off in gradle.properties and replaced with
// versionCode * 10 + abi, the scheme fdroiddata's Flutter template expects:
//
//   1.0.0+1  ->  armeabi-v7a 11, arm64-v8a 12, x86_64 13
//   1.0.1+2  ->  armeabi-v7a 21, arm64-v8a 22, x86_64 23
//
// Only outputs carrying an ABI filter are touched. A universal APK and the Play
// App Bundle keep the plain pubspec version code.
val abiDigits = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)

androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { output ->
            val abi = output.filters.firstOrNull {
                it.filterType ==
                    com.android.build.api.variant.FilterConfiguration.FilterType.ABI
            }?.identifier ?: return@forEach
            val digit = abiDigits[abi] ?: return@forEach
            output.versionCode.set(flutter.versionCode * 10 + digit)
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
