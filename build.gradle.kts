plugins {
}

group = "org.example"
version = "0.1.0"

repositories {
}

dependencies {
}

tasks.register<Exec>("run") {
    group = "love2d"
    workingDir(projectDir.resolve("src"))
    commandLine("love", ".")
}

tasks.register<Zip>("dist") {
    group = "love2d"
    from("$projectDir/src")
    archiveFileName.set("game.love")
    destinationDirectory.set(projectDir.resolve("dist"))
}
