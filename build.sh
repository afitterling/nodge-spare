#!/bin/bash
# Builds NodgeSpare.app into dist/.
#   ./build.sh              native arch, release
#   UNIVERSAL=1 ./build.sh  arm64 + x86_64 fat binary
set -euo pipefail

APP_NAME="NodgeSpare"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/dist/$APP_NAME.app"

# Bash 3.2 (macOS stock) errors on empty array expansion under `set -u`, hence the +/- guard.
ARCH_FLAGS=()
if [[ "${UNIVERSAL:-0}" == "1" ]]; then
  ARCH_FLAGS=(--arch arm64 --arch x86_64)
fi
ARCHS=(${ARCH_FLAGS[@]+"${ARCH_FLAGS[@]}"})

echo "==> Compiling (release)"
swift build -c release --package-path "$ROOT" ${ARCHS[@]+"${ARCHS[@]}"}
BIN_DIR="$(swift build -c release --package-path "$ROOT" ${ARCHS[@]+"${ARCHS[@]}"} --show-bin-path)"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

# Ad-hoc signature. Enough for local use; replace with a Developer ID identity
# (CODESIGN_ID=...) if you want Launch at Login to survive Gatekeeper on other Macs.
echo "==> Signing (${CODESIGN_ID:--} identity)"
codesign --force --options runtime --sign "${CODESIGN_ID:--}" "$APP"

echo "==> Built $APP"
