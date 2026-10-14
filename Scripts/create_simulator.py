#!/usr/bin/env python3
"""Create one owned simulator from the installed iOS runtimes and device types."""

import argparse
import json
import subprocess
import sys
import uuid

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("kind", choices=["iphone", "ipad"])
parser.add_argument("--runtime", help="Installed iOS version, for example 26.5")
args = parser.parse_args()


def inventory(kind):
    result = subprocess.run(["xcrun", "simctl", "list", kind, "--json"], check=True, capture_output=True, text=True)
    return json.loads(result.stdout)[kind]


def version(value):
    return (tuple(int(part) for part in value.split(".")) + (0, 0, 0))[:3]


sdk = subprocess.run(
    ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"],
    check=True, capture_output=True, text=True
).stdout.strip()
runtimes = [
    runtime for runtime in inventory("runtimes")
    if runtime.get("isAvailable") and ".iOS-" in runtime["identifier"]
    and version(runtime["version"]) <= version(sdk)
    and (args.runtime is None or runtime["version"] == args.runtime)
]
if not runtimes:
    sys.exit(f"No matching installed iOS runtime supported by SDK {sdk}. Install one in Xcode Settings > Components.")
runtime = max(runtimes, key=lambda item: version(item["version"]))
parts = version(runtime["version"]) + (0, 0)
runtime_number = (parts[0] << 16) | (parts[1] << 8) | parts[2]
family = "iPhone" if args.kind == "iphone" else "iPad"
devices = [
    device for device in inventory("devicetypes")
    if device.get("productFamily") == family
    and device.get("minRuntimeVersion", 0) <= runtime_number <= device.get("maxRuntimeVersion", 2**32)
]
if not devices:
    sys.exit(f"No {family} device type supports iOS {runtime['version']}.")
preferred = [device for device in devices if "Pro" in device["name"] and "Max" not in device["name"]]
device = (preferred or devices)[0]
name = f"AdaptiveShell {family} {uuid.uuid4().hex[:8]}"
result = subprocess.run(
    ["xcrun", "simctl", "create", name, device["identifier"], runtime["identifier"]],
    check=True, capture_output=True, text=True
)
print(f"Created {name}: {device['name']}, iOS {runtime['version']}", file=sys.stderr)
print(result.stdout.strip())
