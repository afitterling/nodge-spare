// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NodgeSpare",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "NodgeSpare",
            path: "Sources/NodgeSpare"
        )
    ]
)
