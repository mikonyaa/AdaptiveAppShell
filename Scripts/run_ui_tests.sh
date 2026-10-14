#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KIND="${1:-iphone}"
OUTPUT_BASE="${ADAPTIVE_SHELL_TEST_OUTPUT_DIR:-$ROOT/DerivedData-qa-$KIND}"
OUTPUT="$OUTPUT_BASE/$(date -u '+%Y%m%dT%H%M%SZ')-$$"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/adaptive-shell-tests.XXXXXX")"
DEVICE_ID=""

cleanup() {
  if [ -n "$DEVICE_ID" ]; then
    xcrun simctl shutdown "$DEVICE_ID" >/dev/null 2>&1 || true
    xcrun simctl delete "$DEVICE_ID" >/dev/null 2>&1 || true
  fi
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

for tool in xcodebuild xcrun python3 xcodegen swift; do
  command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done
mkdir -p "$OUTPUT/results"
DEVICE_ID="$(python3 "$ROOT/Scripts/create_simulator.py" "$KIND")"
xcrun simctl boot "$DEVICE_ID"
xcrun simctl bootstatus "$DEVICE_ID" -b

run_hosted() {
  local project="$1" scheme="$2" name="$3"
  local derived="$OUTPUT/$name" run_file
  xcodebuild -project "$project" -scheme "$scheme" -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -derivedDataPath "$derived" CODE_SIGNING_ALLOWED=NO build-for-testing
  run_file="$(python3 -c 'import pathlib,sys; files=list(pathlib.Path(sys.argv[1]).glob("*.xctestrun")); assert len(files)==1, files; print(files[0])' "$derived/Build/Products")"
  xcodebuild -xctestrun "$run_file" -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -resultBundlePath "$OUTPUT/results/$name.xcresult" -collect-test-diagnostics never \
    -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test-without-building
}

run_hosted "$ROOT/Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj" AdaptiveShellDemo demo

CONSUMER="$TEMP_ROOT/consumer"
python3 "$ROOT/Scripts/prepare_consumer.py" "$CONSUMER"
swift package --package-path "$CONSUMER" resolve
swift build --package-path "$CONSUMER"
(
  cd "$CONSUMER"
  xcodegen generate
)
run_hosted "$CONSUMER/ConsumerHost.xcodeproj" ConsumerHost consumer
