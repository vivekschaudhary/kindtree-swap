// swift-tools-version: 6.0
import PackageDescription

// Layering is enforced by target dependencies:
//   Features -> Services -> Networking -> Core
// Features can not import Networking directly.
let package = Package(
    name: "KindTreeKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "Features", targets: ["Features"]),
    ],
    targets: [
        .target(name: "Core"),
        .target(name: "Networking", dependencies: ["Core"]),
        .target(name: "Services", dependencies: ["Core", "Networking"]),
        .target(name: "Features", dependencies: ["Core", "Services"]),

        .testTarget(name: "CoreTests", dependencies: ["Core"]),
        .testTarget(name: "NetworkingTests", dependencies: ["Core", "Networking"]),
        .testTarget(name: "ServicesTests", dependencies: ["Core", "Networking", "Services"]),
        .testTarget(name: "FeaturesTests", dependencies: ["Core", "Services", "Features"]),
    ]
)
