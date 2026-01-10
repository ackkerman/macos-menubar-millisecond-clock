#!/usr/bin/env bash
set -euo pipefail

APP_NAME="msbar"
BIN=".build/release/${APP_NAME}"
APP="${APP_NAME}.app"

rm -rf "${APP}"
mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"

cp "${BIN}" "${APP}/Contents/MacOS/${APP_NAME}"

cat > "${APP}/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>msbar</string>
  <key>CFBundleDisplayName</key><string>msbar</string>
  <key>CFBundleIdentifier</key><string>local.msbar</string>
  <key>CFBundleExecutable</key><string>msbar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

# ad-hoc署名（ローカル用途）。失敗しても継続。
codesign --force --deep --sign - "${APP}" || true

echo "Built: ${APP}"
