#!/usr/bin/env python3
"""Create a standalone public-API consumer outside the package checkout."""

import argparse
import json
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("output", type=Path)
parser.add_argument("--version", help="Resolve a released version instead of the local checkout")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
output = args.output.resolve()
if output == root or root in output.parents:
    parser.error("consumer output must be outside the library checkout")
if output.exists():
    parser.error("consumer output already exists; choose a fresh directory")
source = output / "Sources" / "ConsumerBoundary"
source.mkdir(parents=True)
fixture = root / "Tests" / "ConsumerFixture"
shutil.copy2(fixture / "ConsumerView.swift", source)
(output / "ConsumerHost").mkdir()
(output / "ConsumerUITests").mkdir()
shutil.copy2(fixture / "ConsumerApp.swift", output / "ConsumerHost")
shutil.copy2(fixture / "ConsumerUITests.swift", output / "ConsumerUITests")
repository = "https://github.com/mikonyaa/AdaptiveAppShell.git"
dependency = (
    f".package(url: {json.dumps(repository)}, exact: {json.dumps(args.version)})"
    if args.version else f".package(path: {json.dumps(str(root))})"
)
(output / "Package.swift").write_text(f"""// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "ConsumerBoundary",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "ConsumerBoundary", targets: ["ConsumerBoundary"])],
    dependencies: [{dependency}],
    targets: [.target(name: "ConsumerBoundary", dependencies: [
        .product(name: "AdaptiveAppShell", package: "AdaptiveAppShell")
    ])]
)
""")
package_spec = (
    f"url: {repository}\n    exactVersion: {args.version}"
    if args.version else f"path: {json.dumps(str(root))}"
)
(output / "project.yml").write_text(f"""name: ConsumerHost
options:
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "26.0"
packages:
  AdaptiveAppShell:
    {package_spec}
settings:
  base:
    SWIFT_VERSION: "6.0"
    GENERATE_INFOPLIST_FILE: YES
    CODE_SIGNING_ALLOWED: NO
    TARGETED_DEVICE_FAMILY: "1,2"
targets:
  ConsumerHost:
    type: application
    platform: iOS
    sources: [ConsumerHost, Sources/ConsumerBoundary]
    dependencies:
      - package: AdaptiveAppShell
        product: AdaptiveAppShell
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: dev.adaptiveshell.consumer
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations: "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"
  ConsumerHostUITests:
    type: bundle.ui-testing
    platform: iOS
    sources: [ConsumerUITests]
    dependencies:
      - target: ConsumerHost
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: dev.adaptiveshell.consumer.uitests
schemes:
  ConsumerHost:
    build:
      targets:
        ConsumerHost: all
    test:
      targets: [ConsumerHostUITests]
""")
print(output)
