#!/usr/bin/env bash
set -euo pipefail

COLIMA_FLAGS="--cpu 4 --memory 8 --disk 60 --vm-type vz --vz-rosetta"
PLIST_PATH="$HOME/Library/LaunchAgents/com.colima.autostart.plist"
COLIMA_BIN="$(brew --prefix)/bin/colima"

echo "==> Starting Colima..."
if colima status 2>/dev/null; then
  echo "    Colima is already running, skipping start."
else
  colima start $COLIMA_FLAGS
fi

echo "==> Installing Colima LaunchAgent..."
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.colima.autostart</string>
  <key>ProgramArguments</key>
  <array>
    <string>${COLIMA_BIN}</string>
    <string>start</string>
    <string>--cpu</string>
    <string>4</string>
    <string>--memory</string>
    <string>8</string>
    <string>--disk</string>
    <string>60</string>
    <string>--vm-type</string>
    <string>vz</string>
    <string>--vz-rosetta</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/colima-autostart.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/colima-autostart.log</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "==> Colima configured and LaunchAgent installed."
