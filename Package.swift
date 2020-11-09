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
    ],
    targets: [
        .target(
            name: "PublicSuffix",
            resources: [
                .copy("public_suffix_list.dat")
            ]
        ),
        .testTarget(name: "PublicSuffixTests", dependencies: ["PublicSuffix"]),
    ]
)
