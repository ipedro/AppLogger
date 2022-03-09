// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "AppLogger",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AppLogger",
            targets: [
                "AppLogger"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUI-Plus/ActivityView.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AppLogger",
            dependencies: [
                "ActivityView"
            ]
        ),
        .testTarget(
            name: "AppLoggerTests",
            dependencies: [
                "AppLogger"
            ]
        )
    ]
)
