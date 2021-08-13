// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "APIBuilder",
  platforms: [.macOS("11.0")],
  products: [
    .library(name: "APIBuilder", targets: ["APIBuilder"]),
    .library(name: "APIBuilderTestHelpers", targets: ["TestHelpers"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sergiocampama/WebLinking", .branch("main")),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.30.0"),
  ],
  targets: [
    .target(
        name: "APIBuilder",
        dependencies: [
            .product("WebLinking", "WebLinking"),
            .product("swift-nio", "NIO"),
        ]
    ),

    .target(name: "TestHelpers", dependencies: ["APIBuilder"]),
    .testTarget(name: "APIBuilderTests", dependencies: ["APIBuilder", "TestHelpers"]),
  ]
)

extension Target.Dependency {
  static func product(
    _ package: String,
    _ name: String,
    _ condition: TargetDependencyCondition? = nil
  ) -> Self {
    .product(name: name, package: package, condition: condition)
  }
}
