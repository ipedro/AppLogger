// swift-tools-version: 6.0

import PackageDescription

/// Information about the current state of the package's git repository.
let git = Context.gitInformation

/// Whether or not this package is being built for development rather than
/// distribution as a package dependency.
let buildingForDevelopment = (git?.currentTag == nil)

let package = Package(
    name: "AppLogger",
    platforms: [
        .iOS(.v15),
    ],
    products: {
        var products = [Product]()
        products.append(
            .library(
                name: "AppLogger",
                targets: [
                    "AppLogger",
                ]
            )
        )

        if buildingForDevelopment {
            products.append(
                .library(
                    name: "AppLoggerModels",
                    targets: ["Models"]
                )
            )
            products.append(
                .library(
                    name: "AppLoggerData",
                    targets: ["Data"]
                )
            )
            products.append(
                .library(
                    name: "AppLoggerUI",
                    targets: ["UI"]
                )
            )
        }
        return products
    }(),
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
            swiftSettings: buildingForDevelopment ? [.define("DEBUG_VIEWS")] : []
        ),
        .target(
            name: "AppLogger",
            dependencies: [
                "UI",
                "Data",
                "Models",
            ]
        ),
        .testTarget(
            name: "AppLoggerTests",
            dependencies: [
                "AppLogger",
            ]
        ),
    ],
    swiftLanguageModes: [.v5, .v6]
)
