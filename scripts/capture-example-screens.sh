#!/usr/bin/env bash
# Captures the README screenshots of the MigrationLab example app on an iPhone simulator.
#
# The script builds and installs the app, opens each tab with `-screen <name>` (the Liquid Glass
# tab with its tool palette expanded) and one rule with `-rule <id>`, which goes through the same
# validation as a migrationlab:// URL, and takes a simulator screenshot of each in light and dark
# appearance with a fixed status bar and English system text. Nothing is drawn by hand: every
# image is the running app.
#
# Usage: scripts/capture-example-screens.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.MigrationLab"
screens=(scanner rules glass scene)
output_dir="$repo_root/docs/images"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$output_dir"

echo "Building MigrationLab for '$device'"
destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi
xcodebuild build \
  -project "$repo_root/Examples/MigrationLab/MigrationLab.xcodeproj" \
  -scheme MigrationLab \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'MigrationLab.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl install "$device" "$app"

capture() {
  local file="$output_dir/example-$1-$2.png"
  xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
  # Half the width of an iPhone screenshot keeps the README light.
  sips --resampleWidth 603 "$file" >/dev/null
  echo "$file"
}

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  for screen in "${screens[@]}" rule; do
    arguments=(-screen "$screen" -expanded)
    if [[ "$screen" == rule ]]; then arguments=(-rule scene-manifest-missing); fi
    xcrun simctl launch --terminate-running-process "$device" "$bundle_id" \
      "${arguments[@]}" -AppleLanguages "(en)" -AppleLocale en_US >/dev/null
    sleep 4 # launch, first layout and the glass animation
    capture "$screen" "$appearance"
  done
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
