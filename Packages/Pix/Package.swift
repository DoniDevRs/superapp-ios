// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Pix",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "Pix", targets: ["Pix"])
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "Pix",
            dependencies: ["Core"],
            path: "Sources/Pix"
        ),
        .testTarget(
            name: "PixTests",
            dependencies: ["Pix"],
            path: "Tests/PixTests"
        )
    ]
)
