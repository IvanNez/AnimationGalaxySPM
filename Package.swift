// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimationGalaxySPM",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AnimationGalaxySPM",
            targets: ["AnimationGalaxySPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "AnimationGalaxySPM",
            dependencies: []),
        .testTarget(
            name: "AnimationGalaxySPMTests",
            dependencies: ["AnimationGalaxySPM"]),
    ]
)
