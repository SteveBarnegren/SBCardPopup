// swift-tools-version:5.1
import PackageDescription

let package = Package(name: "SBCardPopup",
                      platforms: [.iOS(.v12)],
                      products: [.library(name: "SBCardPopup",
                                          targets: ["SBCardPopup"])],
                      targets: [.target(name: "SBCardPopup",
                                        path: "SBCardPopup/SBCardPopup")],
                      swiftLanguageVersions: [.v5])
