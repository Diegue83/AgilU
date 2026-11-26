import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Llave de firma de las versiones publicadas. android/key.properties no se
// versiona (ver .gitignore); en GitHub Actions se escribe desde los secretos.
// Sin ese archivo, el release se firma con la llave de depuración de esta
// computadora y no podrá instalarse encima de una versión publicada.
val llaveRelease = Properties().apply {
    val archivo = rootProject.file("key.properties")
    if (archivo.exists()) FileInputStream(archivo).use { load(it) }
}
val conLlaveRelease = llaveRelease.getProperty("storeFile") != null

android {
    namespace = "com.example.agilu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.agilu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (conLlaveRelease) {
            create("release") {
                storeFile = file(llaveRelease.getProperty("storeFile"))
                storePassword = llaveRelease.getProperty("storePassword")
                keyAlias = llaveRelease.getProperty("keyAlias")
                keyPassword = llaveRelease.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (conLlaveRelease) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    // FileProvider para entregar el APK descargado al instalador de Android.
    implementation("androidx.core:core-ktx:1.13.1")
}

flutter {
    source = "../.."
}
