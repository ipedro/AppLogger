// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swiftui-visual-logger",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "VisualLogger",
            targets: [
                "VisualLogger",
            ]
        )
    ],
    targets: [
        .target(
            name: "Models"
        ),
        .target(
            name: "Data",
            dependencies: ["Models"]
        ),
        .target(
            name: "UI",
            dependencies: ["Data"],
        ),
        .target(
            name: "VisualLogger",
            dependencies: [
                "UI",
                "Data",
                "Models",
            ]
        ),
    ]
)
