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

tasks.register<Zip>("dist-love-file") {
    group = "love2d"
    from("$projectDir/src")
    archiveFileName.set("game.love")
    destinationDirectory.set(projectDir.resolve("dist"))
    doFirst {
        file("$projectDir/src/_deploy.lua").writeText("isLiveBuild = true\n")
    }
}

tasks.register<Exec>("dist-web-create-files") {
    group = "love2d"
    dependsOn("dist-love-file")
    workingDir(projectDir.resolve("dist"))
    commandLine("npx.cmd", "love.js.cmd", "-t", "babamotes-gamejam", "./game.love", "./web/")
}

tasks.register<Zip>("dist-web-zip") {
    group = "love2d"
    dependsOn("dist-web-create-files")
    from("$projectDir/dist/web")
    archiveFileName.set("game-web.zip")
    destinationDirectory.set(projectDir.resolve("dist"))
    doLast {
        file("$projectDir/src/_deploy.lua").writeText("isLiveBuild = false\n")
    }
}
