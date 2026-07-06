#!/bin/zsh

set -euo pipefail

ROOT="${0:A:h:h}"
PROJECT="$ROOT/Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj"
DERIVED_DATA="$ROOT/DerivedData"
APP="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/AdaptiveShellDemo.app"
BUNDLE_ID="dev.liquidglasstemplates.adaptiveshell.demo"
DEVICE_ID="${ADAPTIVE_SHELL_DEVICE_ID:-58A90F38-36E7-4A46-93ED-E2E7714CD0A4}"
RECORDING="$ROOT/Assets/GIFs/showcase-source.mov"
GIF="$ROOT/Assets/GIFs/adaptive-app-shell.gif"
BUILD_LOG="$DERIVED_DATA/showcase-build.log"

mkdir -p "$DERIVED_DATA" "$ROOT/Assets/GIFs"

xcodebuild \
  -project "$PROJECT" \
  -scheme AdaptiveShellDemo \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build > "$BUILD_LOG"

xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl uninstall "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$DEVICE_ID" "$APP"
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" --showcase

sleep 1
xcrun simctl io "$DEVICE_ID" recordVideo --codec=h264 --force "$RECORDING" &
RECORDING_PID=$!

sleep 8.5
kill -INT "$RECORDING_PID" || true
wait "$RECORDING_PID" || true

ffmpeg -y -ss 1 -i "$RECORDING" \
  -filter_complex "fps=12,scale=320:-1:flags=lanczos,split[frames][palette_input];[palette_input]palettegen=max_colors=160:stats_mode=diff[palette];[frames][palette]paletteuse=dither=sierra2_4a:diff_mode=rectangle" \
  -loop 0 "$GIF" >/dev/null 2>&1

echo "$GIF"
echo "$BUILD_LOG"
