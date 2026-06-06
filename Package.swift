// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyLlama",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "EasyLlama",
            targets: ["EasyLlama"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pgorzelany/swift-llama-cpp.git", branch: "main")
    ],
    targets: [
        .target(
            name: "EasyLlama",
            dependencies: [
                .product(name: "SwiftLlama", package: "swift-llama-cpp")
            ]
        ),
        .testTarget(
            name: "EasyLlamaTests",
            dependencies: ["EasyLlama"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
