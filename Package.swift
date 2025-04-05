// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "AppLogger",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppLogger",
            targets: [
                "AppLogger"
            ]
        )
    ],
    targets: [
        .target(name: "AppLogger"),
        .testTarget(
            name: "AppLoggerTests",
            dependencies: [
                "AppLogger"
            ]
        )
    ]
)
