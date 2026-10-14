#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj"
DERIVED_DATA="$ROOT/DerivedData-showcase"
APP="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/AdaptiveShellDemo.app"
BUNDLE_ID="dev.liquidglasstemplates.adaptiveshell.demo"
DEVICE_ID=""
RECORDING_PID=""
CAPTURE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/adaptive-shell-capture.XXXXXX")"
RECORDING="$CAPTURE_DIR/showcase-source.mov"
GIF="$ROOT/Assets/GIFs/adaptive-app-shell.gif"
BUILD_LOG="$DERIVED_DATA/showcase-build.log"

cleanup() {
  if [ -n "$RECORDING_PID" ]; then
    kill -INT "$RECORDING_PID" >/dev/null 2>&1 || true
    wait "$RECORDING_PID" >/dev/null 2>&1 || true
  fi
  if [ -n "$DEVICE_ID" ]; then
    xcrun simctl shutdown "$DEVICE_ID" >/dev/null 2>&1 || true
    xcrun simctl delete "$DEVICE_ID" >/dev/null 2>&1 || true
  fi
  rm -rf "$CAPTURE_DIR"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

for tool in xcodebuild xcrun python3 ffmpeg; do
  command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done
mkdir -p "$DERIVED_DATA" "$ROOT/Assets/GIFs"
if [ -n "${ADAPTIVE_SHELL_RUNTIME:-}" ]; then
  DEVICE_ID="$(python3 "$ROOT/Scripts/create_simulator.py" iphone --runtime "$ADAPTIVE_SHELL_RUNTIME")"
else
  DEVICE_ID="$(python3 "$ROOT/Scripts/create_simulator.py" iphone)"
fi
xcrun simctl boot "$DEVICE_ID"
xcrun simctl bootstatus "$DEVICE_ID" -b

xcodebuild \
  -project "$PROJECT" \
  -scheme AdaptiveShellDemo \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build > "$BUILD_LOG"

xcrun simctl install "$DEVICE_ID" "$APP"
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null
sleep 2
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" --showcase

sleep 1.8
xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --force "$RECORDING" &
RECORDING_PID=$!

sleep 13
kill -INT "$RECORDING_PID" || true
wait "$RECORDING_PID" || true
RECORDING_PID=""

cp "$RECORDING" "$ROOT/Assets/GIFs/showcase-source.mov"
ffmpeg -y -i "$RECORDING" \
  -filter_complex "fps=20,scale=400:-1:flags=lanczos,split[frames][palette_input];[palette_input]palettegen=max_colors=128:stats_mode=diff[palette];[frames][palette]paletteuse=dither=none:diff_mode=rectangle" \
  -loop 0 "$GIF" >/dev/null 2>&1

echo "$GIF"
echo "$BUILD_LOG"
