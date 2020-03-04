// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
// We're hiding dev, test, and danger dependencies with // dev to make sure they're not fetched by users of this package.

import PackageDescription

let package = Package(
    name: "Diagnostics",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v10),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Diagnostics",
            type: .dynamic,
            targets: ["Diagnostics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Diagnostics",
            dependencies: [],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
