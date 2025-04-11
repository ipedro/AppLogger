// swift-tools-version: 6.0

import PackageDescription

/// Information about the current state of the package's git repository.
let git = Context.gitInformation

/// Whether or not this package is being built for development rather than
/// distribution as a package dependency.
let buildingForDevelopment = (git?.currentTag == nil)

let package = Package(
    name: "swiftui-visual-logger",
    platforms: [
        .iOS(.v15),
    ],
    products: {
        var products = [Product]()
        products.append(
            .library(
                name: "VisualLogger",
                targets: [
                    "VisualLogger",
                ]
            )
        )

        if buildingForDevelopment {
            products.append(
                .library(
                    name: "VisualLoggerModels",
                    targets: ["Models"]
                )
            )
            products.append(
                .library(
                    name: "VisualLoggerData",
                    targets: ["Data"]
                )
            )
            products.append(
                .library(
                    name: "VisualLoggerUI",
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
            name: "VisualLogger",
            dependencies: [
                "UI",
                "Data",
                "Models",
            ]
        ),
    ],
    swiftLanguageModes: [.v5, .v6]
)
