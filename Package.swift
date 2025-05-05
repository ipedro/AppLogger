// swift-tools-version: 6.0

import PackageDescription

/// Information about the current state of the package's git repository.
let git = Context.gitInformation

/// Whether or not this package is being built for development rather than
/// distribution as a package dependency.
let buildingForDevelopment = (git?.currentTag == nil)

func make<T>(_ default: T..., development: @autoclosure () -> [T]) -> [T] {
    if buildingForDevelopment {
        `default` + development()
    } else {
        `default`
    }
}

let package = Package(
    name: "swiftui-visual-logger",
    platforms: [
        .iOS(.v15),
    ],
    products: make(
        .library(
            name: "VisualLogger",
            targets: [
                "VisualLogger",
            ]
        ),
        development: [
            .library(
                name: "VisualLoggerModels",
                targets: ["Models"]
            ),
            .library(
                name: "VisualLoggerData",
                targets: ["Data"]
            ),
            .library(
                name: "VisualLoggerUI",
                targets: ["UI"]
            ),
        ]
    ),
    dependencies: make(development: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", branch: "6.1.0"),
    ]),
    targets: make(
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
            swiftSettings: make(development: [
                .define("DEBUG_VIEWS")
            ])
        ),
        .target(
            name: "VisualLogger",
            dependencies: [
                "UI",
                "Data",
                "Models",
            ]
        ),
        development: [
            .testTarget(
                name: "DataTests",
                dependencies: [
                    "Data",
                    "Models",
                    .product(name: "Testing", package: "swift-testing"),
                ]
            ),
        ]
    ),
    swiftLanguageModes: [
        .v5,
        .v6
    ]
)
