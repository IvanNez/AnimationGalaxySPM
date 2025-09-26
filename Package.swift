// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimationGalaxySPM",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "AnimationGalaxySPM", targets: ["AnimationGalaxySPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.15.0"),
    ],
    targets: [
        .target(
            name: "AnimationGalaxySPM",
            dependencies: [
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift") // ← вот так
            ]
        ),
        .testTarget(
            name: "AnimationGalaxySPMTests",
            dependencies: ["AnimationGalaxySPM"]
        ),
    ]
)
