// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CoinAPI",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "CoinAPI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "PostgresClientKit", package: "PostgresClientKit")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "CoinAPITests",
            dependencies: [
                .target(name: "CoinAPI"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
