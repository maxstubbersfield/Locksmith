// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ares_defence_labs_lock_smith_pdf",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(
            name: "ares-defence-labs-lock-smith-pdf",
            targets: ["ares_defence_labs_lock_smith_pdf"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ares_defence_labs_lock_smith_pdf",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
