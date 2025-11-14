plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.datadate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.datadate.datingapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled true
       
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
        }
    }
       signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties["keyAlias"]
                keyPassword keystoreProperties["keyPassword"]
                storeFile file(keystoreProperties["storeFile"])
                storePassword keystoreProperties["storePassword"]
            } else {
                println("⚠️ Warning: Release signing not configured.")
            }
        }
    }

     buildTypes {
        debug {}

        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true

          
        }
    }

    
    bundle {
        abi { enableSplit = false }
        density { enableSplit = false }
        language { enableSplit = false }
    }

    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

}

flutter {
    source = "../.."
}

dependencies {
    // Java 8+ desugaring support
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'

    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'androidx.window:window:1.2.0'
    implementation 'androidx.window:window-java:1.2.0'
    implementation 'com.google.android.gms:play-services-ads-identifier:18.0.1'

    // // In-App Review and Play Asset Delivery
    // implementation("com.google.android.play:asset-delivery:2.3.0")
    // implementation("com.google.android.play:asset-delivery-ktx:2.3.0")
    // implementation("com.google.android.play:review:2.0.2")
    // implementation("com.google.android.play:review-ktx:2.0.2")

    // Optional dynamic features (uncomment if needed)
    // implementation("com.google.android.play:feature-delivery:2.1.0")
    // implementation("com.google.android.play:feature-delivery-ktx:2.1.0")
}

