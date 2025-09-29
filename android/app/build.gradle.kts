plugins {
    id("com.android.application")
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
        getByName("debug")    { 
            applicationIdSuffix = ".debug"
            resValue("string", "app_name", "HabitTracker-debug-${defaultConfig.versionName}.${defaultConfig.versionCode}")
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release")  { isMinifyEnabled = true;  // keep your proguard if any
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            resValue("string", "app_name", "HabitTracker-${defaultConfig.versionName}.${defaultConfig.versionCode}")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
