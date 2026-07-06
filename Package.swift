// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AdaptiveAppShell",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AdaptiveAppShell", targets: ["AdaptiveAppShell"])
    ],
    targets: [
        .target(name: "AdaptiveAppShell"),
        .testTarget(
            name: "AdaptiveAppShellTests",
            dependencies: ["AdaptiveAppShell"]
        )
    ]
)
