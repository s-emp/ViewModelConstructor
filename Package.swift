// swift-tools-version: 6.2
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ViewModelConstructor",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ViewModelConstructorCore",
            targets: ["ViewModelConstructorCore"]
        ),
        .library(
            name: "ViewModelConstructorUI",
            targets: ["ViewModelConstructorUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
    ],
    targets: [
        .target(
            name: "ViewModelConstructorCore",
            dependencies: ["ViewModelConstructorMacros"]
        ),
        .macro(
            name: "ViewModelConstructorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "ViewModelConstructorUI",
            dependencies: ["ViewModelConstructorCore"]
        ),
        .testTarget(
            name: "ViewModelConstructorMacroTests",
            dependencies: [
                "ViewModelConstructorMacros",
                "ViewModelConstructorCore",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "ViewModelConstructorCoreTests",
            dependencies: ["ViewModelConstructorCore"]
        ),
    ]
)
