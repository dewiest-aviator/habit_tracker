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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.raijinryu.habittracker"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            fun gp(name: String): String? = project.findProperty(name) as String?

            // Priority: CI secrets via env (ANDROID_RELEASE_*) -> user global gradle props (HABITTRACKER_RELEASE_*) -> fallback project props (ANDROID_RELEASE_*)
            val storeFilePath = System.getenv("ANDROID_RELEASE_STORE_FILE")
                ?: gp("HABITTRACKER_RELEASE_STORE_FILE")
                ?: gp("ANDROID_RELEASE_STORE_FILE")
                ?: ""

            storeFile = if (storeFilePath.isNotBlank()) file(storeFilePath) else null
            storePassword = System.getenv("ANDROID_RELEASE_STORE_PASSWORD")
                ?: gp("HABITTRACKER_RELEASE_STORE_PASSWORD")
                ?: gp("ANDROID_RELEASE_STORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_RELEASE_KEY_ALIAS")
                ?: gp("HABITTRACKER_RELEASE_KEY_ALIAS")
                ?: gp("ANDROID_RELEASE_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_RELEASE_KEY_PASSWORD")
                ?: gp("HABITTRACKER_RELEASE_KEY_PASSWORD")
                ?: gp("ANDROID_RELEASE_KEY_PASSWORD")
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
            resValue("string", "app_name", "Habit Tracker DEV")
            buildConfigField("String", "FLAVOR", "\"dev\"")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "Habit Tracker STG")
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
