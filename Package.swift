// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PublicSuffix",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .macOS(.v10_10),
    ],
    products: [
        .library(name: "PublicSuffix", targets: ["PublicSuffix"]),
        .library(name: "PublicSuffix_NoBundled", targets: ["PublicSuffix_NoBundled"]),
    ],
    targets: [
        .target(
            name: "PublicSuffix",
            resources: [
                .copy("public_suffix_list.dat")
            ]
        ),
        .target(
            name: "PublicSuffix_NoBundled",
            exclude: ["public_suffix_list.dat"],
            swiftSettings: [.define("NO_BUNDLED")]
        ),
        .testTarget(name: "PublicSuffixTests", dependencies: ["PublicSuffix"]),
    ]
)
