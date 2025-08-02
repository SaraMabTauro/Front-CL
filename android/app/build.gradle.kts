import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))

    println("DEBUG: storeFile=${keystoreProperties["storeFile"]}")
    println("DEBUG: storePassword=${keystoreProperties["storePassword"]}")
    println("DEBUG: keyAlias=${keystoreProperties["keyAlias"]}")
    println("DEBUG: keyPassword=${keystoreProperties["keyPassword"]}")
} else {
    throw GradleException("Archivo key.properties no encontrado.")
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // debe ir después de Android y Kotlin
}

android {
    namespace = "com.example.smart_habits"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_habits"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

println("DEBUG: Ruta absoluta a JKS = ${file(keystoreProperties["storeFile"] as String).absolutePath}")
println("DEBUG: Existe el archivo JKS = ${file(keystoreProperties["storeFile"] as String).exists()}")


    signingConfigs {
        create("release") {
            val keystorePath = keystoreProperties["storeFile"] as? String
                ?: throw GradleException("Falta storeFile en key.properties")
            storeFile = file(keystorePath)
            storePassword = keystoreProperties["storePassword"] as? String
                ?: throw GradleException("Falta storePassword en key.properties")
            keyAlias = keystoreProperties["keyAlias"] as? String
                ?: throw GradleException("Falta keyAlias en key.properties")
            keyPassword = keystoreProperties["keyPassword"] as? String
                ?: throw GradleException("Falta keyPassword en key.properties")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
