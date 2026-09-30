allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Android 17 ships as the platform package "android-37.0", but AGP turns a
// bare `compileSdk 37` into the lookup hash "android-37", which is not found
// when Gradle installs the platform mid-build (fresh CI, F-Droid's server).
// app/build.gradle.kts fixes its own module; this does the same for every
// plugin module, since receive_sharing_intent asks for a bare 37 and plugin
// build files live in the pub cache where we cannot edit them.
//
// finalizeDsl runs after a module's own build script and before AGP locks
// the DSL, so it sees the plugin's value and can still change it. Only a bare
// 37 is touched: an explicit minor level, or any other API, is left alone.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { android ->
                if (android.compileSdk == 37 && android.compileSdkMinor == null) {
                    android.compileSdkMinor = 0
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
