plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lockin"
    compileSdk = flutter.compileSdkVersion  // أو 36 صراحة

    defaultConfig {
        applicationId = "com.example.lockin"
        minSdk = flutter.minSdkVersion       // خليها كده عشان Flutter مش يعدلها تاني
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // مهم جدًا للـ release build عشان يشتغل بدون مشاكل التوقيع
    buildTypes {
        release {
            // استخدم debug signing مؤقتًا عشان الـ testing و flutter run --release
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // مطلوب للـ flutter_local_notifications exact scheduling
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // Firebase بدون BoM - إصدارات حديثة (ديسمبر 2025)
    implementation("com.google.firebase:firebase-analytics:22.1.2")
    implementation("com.google.firebase:firebase-auth:23.1.2")
    implementation("com.google.firebase:firebase-firestore:25.1.1")  // أو أحدث حسب التحديثات

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.1")  // أحدث stable

    // Desugaring أحدث إصدار معروف (ديسمبر 2025)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Window extensions (محدثة لأحدث stable ديسمبر 2025)
    implementation("androidx.window:window:1.5.1")
    implementation("androidx.window:window-java:1.5.1")
}