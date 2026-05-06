// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "amplitude_experiment",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(
            name: "amplitude-experiment",
            targets: ["amplitude_experiment"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/amplitude/experiment-ios-client.git",
            from: "1.19.0"
        ),
    ],
    targets: [
        // Thin re-export target so plugin sources can `import
        // AmplitudeExperiment` (matching the CocoaPods module name) under
        // SPM, where the upstream module is otherwise named `Experiment`.
        .target(
            name: "AmplitudeExperiment",
            dependencies: [
                .product(
                    name: "Experiment",
                    package: "experiment-ios-client"
                ),
            ],
            path: "Sources/AmplitudeExperiment"
        ),
        .target(
            name: "amplitude_experiment",
            dependencies: [
                "AmplitudeExperiment",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
