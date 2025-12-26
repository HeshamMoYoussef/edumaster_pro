allprojects {
    repositories {
        google()
        mavenCentral()
        // Jitsi Meet Maven Repository
        maven { url = uri("https://github.com/niccokunzmann/nicco-maven/raw/refs/heads/master/jitsi-maven/") }
        maven { url = uri("https://maven.jitsi.org/releases") }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
