// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "clio-domain",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "ClioDomain", targets: ["ClioDomain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/clio-app/clio-entities", branch: "main"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", branch: "master")
    ],
    targets: [
        .target(
            name: "ClioDomain",
            dependencies: [
                .product(name: "ClioEntities", package: "clio-entities"),
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ]
        ),
        .testTarget(
            name: "clio-domainTests",
            dependencies: ["ClioDomain"]
        ),
    ]
)
