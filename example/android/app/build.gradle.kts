import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localPropertiesFile = rootProject.file("local.properties")
val localProperties = Properties().apply {
    load(FileInputStream(localPropertiesFile))
}
android {
    namespace = "com.example.example"
    try {
        compileSdk = Integer.parseInt(localProperties.getProperty("flutter.compileSdkVersion"))
    } catch (e: NumberFormatException) {
        compileSdk = 36
    }
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        try {
            minSdk = Integer.parseInt(localProperties.getProperty("flutter.minSdkVersion"))
        } catch (e: NumberFormatException) {
            minSdk = 24
        }
        try {
            targetSdk = Integer.parseInt(localProperties.getProperty("flutter.targetSdkVersion"))
        } catch (e: NumberFormatException) {
            targetSdk = 36
        }
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
