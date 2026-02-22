#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH="$REPO_ROOT/Pearcleaner.xcodeproj"
SCHEME="Pearcleaner"

BUILD_ROOT="${BUILD_ROOT:-$REPO_ROOT/.build-macos12}"
ARCHIVE_PATH="$BUILD_ROOT/Pearcleaner-macos12.xcarchive"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/Builds/output-macos12}"
APP_PATH="$ARCHIVE_PATH/Products/Applications/Pearcleaner.app"
ZIP_PATH="$OUTPUT_DIR/Pearcleaner-macos12-unsigned.zip"
DMG_PATH="$OUTPUT_DIR/Pearcleaner-macos12-unsigned.dmg"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild was not found. Install full Xcode first."
  exit 1
fi

mkdir -p "$BUILD_ROOT" "$OUTPUT_DIR"
rm -rf "$ARCHIVE_PATH" "$OUTPUT_DIR/Pearcleaner.app" "$ZIP_PATH" "$DMG_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$ARCHIVE_PATH" \
  clean archive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  ENABLE_HARDENED_RUNTIME=NO \
  MACOSX_DEPLOYMENT_TARGET=12.0

cp -R "$APP_PATH" "$OUTPUT_DIR/Pearcleaner.app"

ditto -c -k --sequesterRsrc --keepParent \
  "$OUTPUT_DIR/Pearcleaner.app" \
  "$ZIP_PATH"

DMG_STAGING_DIR="$(mktemp -d "$BUILD_ROOT/dmg-staging.XXXXXX")"
cp -R "$OUTPUT_DIR/Pearcleaner.app" "$DMG_STAGING_DIR/"
ln -s /Applications "$DMG_STAGING_DIR/Applications"

hdiutil create \
  -volname "Pearcleaner macOS12" \
  -srcfolder "$DMG_STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$DMG_STAGING_DIR"

cat <<EOF
Build complete.
App bundle: $OUTPUT_DIR/Pearcleaner.app
ZIP archive: $ZIP_PATH
DMG image:   $DMG_PATH

Install:
1) Open the DMG and drag Pearcleaner.app into /Applications.
2) If Gatekeeper blocks launch, run:
   xattr -dr com.apple.quarantine /Applications/Pearcleaner.app
EOF
