import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // 👈 NAYA: Google Services Plugin apply karo
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 👇 NAYA: local.properties load karo (Version code ke liye)
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// 👇 NAYA: Key properties load karo (Signing ke liye)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.abcitta"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // 👇 Signing Config
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.example.abcitta"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // 👇 FIX: local.properties se version code aur name uthao
        versionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
        versionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"
    }

            // 👈 Build Types
        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("release")
                // 👈 NAYA: Shrinking temporarily disable karo
                isMinifyEnabled = false
                isShrinkResources = false
            }
        }
    } // 👈 YEH BRACKET MISSING THA! Ye android { } ko close kar raha hai

    flutter {
        source = "../.."
    }