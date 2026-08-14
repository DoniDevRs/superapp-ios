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
        .package(path: "../Core"),
        .package(path: "../../../superapp-design-system")
    ],
    targets: [
        .target(
            name: "Pix",
            dependencies: [
                "Core",
                .product(name: "SuperAppDesignSystem", package: "superapp-design-system")
            ],
            path: "Sources/Pix"
        ),
        .testTarget(
            name: "PixTests",
            dependencies: ["Pix"],
            path: "Tests/PixTests"
        )
    ]
)
