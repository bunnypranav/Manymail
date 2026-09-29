import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is opt-in: drop a `key.properties` next to this module's
// parent (android/key.properties) and the release build picks it up with no
// code change. Without it the release build is signed with the debug key, so
// `flutter build apk --release` still works for local installs — but the
// resulting APK is NOT distributable.
//
// android/key.properties (gitignored):
//   storeFile=/absolute/path/to/manymail-release.jks
//   storePassword=...
//   keyAlias=manymail
//   keyPassword=...
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
    compileSdk = 37
    // No plugin in this project compiles native source, so the NDK is not
    // required. Leaving `ndkVersion = flutter.ndkVersion` set makes Gradle try
    // to auto-install it through the deprecated sdkmanager shim, which crashes
    // on the current cmdline-tools. Re-add it if a future dependency needs it.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Debug-signed so a release build still installs locally.
                signingConfigs.getByName("debug")
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

// A loud, unmissable note in the build output rather than a silently
// debug-signed "release" APK.
if (!hasReleaseKeystore) {
    logger.lifecycle(
        "Manymail: android/key.properties not found — release builds will be " +
            "signed with the DEBUG key and are not distributable."
    )
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
