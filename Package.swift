// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "swift-server-sent-event-models",
	products: [
		.library(
			name: "ServerSentEventModels",
			targets: ["ServerSentEventModels"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
	],
	targets: [
		.target(
			name: "ServerSentEventModels",
			dependencies: []
		),
		.testTarget(
			name: "ServerSentEventModelsTests",
			dependencies: ["ServerSentEventModels"]
		),
	]
)
