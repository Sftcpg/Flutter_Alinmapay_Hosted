// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_alinmapay_hosted",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "flutter-alinmapay-hosted", targets: ["flutter_alinmapay_hosted"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_alinmapay_hosted",
            dependencies: []
        )
    ]
)
