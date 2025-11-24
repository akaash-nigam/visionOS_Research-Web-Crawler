// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResearchWebCrawler",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ResearchWebCrawler",
            targets: ["ResearchWebCrawler"]
        )
    ],
    dependencies: [
        // SwiftSoup for HTML parsing
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    ],
    targets: [
        .target(
            name: "ResearchWebCrawler",
            dependencies: ["SwiftSoup"]
        ),
        .testTarget(
            name: "ResearchWebCrawlerTests",
            dependencies: ["ResearchWebCrawler"]
        )
    ]
)
