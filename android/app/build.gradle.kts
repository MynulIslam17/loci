plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Base64
import java.nio.charset.StandardCharsets
import groovy.json.JsonSlurper
import java.io.File

// Extract compile-time dart-defines passed from Flutter (e.g. api_keys.json)
val dartEnvironmentVariables = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val rawDefines = project.property("dart-defines") as String
    rawDefines.split(",").forEach { encoded ->
        try {
            val decoded = String(Base64.getDecoder().decode(encoded), StandardCharsets.UTF_8)
            val parts = decoded.split("=", limit = 2)
            if (parts.size == 2) {
                dartEnvironmentVariables[parts[0]] = parts[1]
            }
        } catch (_: Exception) {
            val parts = encoded.split("=", limit = 2)
            if (parts.size == 2) {
                dartEnvironmentVariables[parts[0]] = parts[1]
            }
        }
    }
}

// Ensure key is read either from dart-defines OR directly from api_keys.json
var googleMapsApiKey = dartEnvironmentVariables["GOOGLE_MAPS_API_KEY"] ?: ""
if (googleMapsApiKey.isEmpty()) {
    val apiKeysFile = File(rootProject.projectDir.parentFile, "api_keys.json")
    if (apiKeysFile.exists()) {
        try {
            val jsonMap = JsonSlurper().parse(apiKeysFile) as? Map<*, *>
            googleMapsApiKey = jsonMap?.get("GOOGLE_MAPS_API_KEY") as? String ?: ""
        } catch (_: Exception) {}
    }
}

android {
    namespace = "ui.neatboutique.jacobi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ui.neatboutique.jacobi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // flutter_stripe requires a minimum SDK of 21.
        minSdk = maxOf(flutter.minSdkVersion, 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // Compile-time Google Maps API key injected from api_keys.json
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
