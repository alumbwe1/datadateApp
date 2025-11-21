import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.datadate.datingapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.datadate.datingapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                println("⚠️ Warning: Release signing not configured.")
            }
        }
    }

    buildTypes {
        debug {}

        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }

    bundle {
        abi { enableSplit = false }
        density { enableSplit = false }
        language { enableSplit = false }
    }

   compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
    implementation("com.google.android.gms:play-services-ads-identifier:18.0.1")
}
