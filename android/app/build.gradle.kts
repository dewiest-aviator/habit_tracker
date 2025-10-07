plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.raijinryu.habittracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.raijinryu.habittracker"
        minSdk = 31
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            fun gp(name: String): String? = project.findProperty(name) as String?

            // Priority: CI secrets via env (ANDROID_*) -> user global gradle props (HABITTRACKER_*) -> fallback project props (ANDROID_*)
            val storeFilePath = System.getenv("ANDROID_STORE_FILE")
                ?: gp("HABITTRACKER_STORE_FILE")
                ?: gp("ANDROID_STORE_FILE")
                ?: ""

            storeFile = if (storeFilePath.isNotBlank()) file(storeFilePath) else null
            storePassword = System.getenv("ANDROID_STORE_PASSWORD")
                ?: gp("HABITTRACKER_STORE_PASSWORD")
                ?: gp("ANDROID_STORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                ?: gp("HABITTRACKER_KEY_ALIAS")
                ?: gp("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                ?: gp("HABITTRACKER_KEY_PASSWORD")
                ?: gp("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("release")  { 
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

    flavorDimensions += listOf("env")

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "DEV • HT")
            buildConfigField("String", "FLAVOR", "\"dev\"")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "STG • HT")
            buildConfigField("String", "FLAVOR", "\"staging\"")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Habit Tracker")
            buildConfigField("String", "FLAVOR", "\"prod\"")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
