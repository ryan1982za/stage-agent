// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StageDesignerCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "StageDesignerDomain", targets: ["StageDesignerDomain"]),
        .library(name: "StageDesignerPersistence", targets: ["StageDesignerPersistence"]),
        .library(name: "StageDesignerApplication", targets: ["StageDesignerApplication"])
    ],
    targets: [
        .target(
            name: "StageDesignerDomain",
            path: "Sources/StageDesignerDomain"
        ),
        .target(
            name: "StageDesignerPersistence",
            dependencies: ["StageDesignerDomain"],
            path: "Sources/StageDesignerPersistence"
        ),
        .target(
            name: "StageDesignerApplication",
            dependencies: ["StageDesignerDomain", "StageDesignerPersistence"],
            path: "Sources/StageDesignerApplication"
        ),
        .testTarget(
            name: "StageDesignerDomainTests",
            dependencies: ["StageDesignerDomain"],
            path: "Tests/StageDesignerDomainTests"
        ),
        .testTarget(
            name: "StageDesignerApplicationTests",
            dependencies: ["StageDesignerApplication", "StageDesignerDomain", "StageDesignerPersistence"],
            path: "Tests/StageDesignerApplicationTests"
        ),
        .testTarget(
            name: "StageDesignerPersistenceTests",
            dependencies: ["StageDesignerPersistence", "StageDesignerDomain"],
            path: "Tests/StageDesignerPersistenceTests"
        )
    ]
)
