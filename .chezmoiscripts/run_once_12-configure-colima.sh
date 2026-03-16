#!/usr/bin/env bash
set -euo pipefail

# Ensure Homebrew is in PATH (chezmoi scripts inherit a minimal environment)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v colima &>/dev/null; then
  echo "==> Colima not installed yet, skipping configuration."
  echo "    Run 'chezmoi apply' again after Homebrew packages are installed."
  exit 0
fi

CPU=4
MEMORY=8
DISK=60
PLIST_PATH="$HOME/Library/LaunchAgents/com.colima.autostart.plist"
COLIMA_BIN="$(brew --prefix)/bin/colima"

# Detect Virtualization.framework support
if sysctl -n kern.hv_support 2>/dev/null | grep -q 1; then
  VM_TYPE="vz"
  MOUNT_TYPE="virtiofs"
  EXTRA_FLAGS="--vz-rosetta"

  # Rosetta is required for --vz-rosetta
  if ! /usr/bin/pgrep -q oahd 2>/dev/null; then
    echo "==> Installing Rosetta..."
    softwareupdate --install-rosetta --agree-to-license || true
  fi
else
  echo "==> Virtualization.framework not available, using QEMU..."
  VM_TYPE="qemu"
  MOUNT_TYPE="sshfs"
  EXTRA_FLAGS=""
fi

COLIMA_FLAGS="--cpu $CPU --memory $MEMORY --disk $DISK --vm-type $VM_TYPE --mount-type $MOUNT_TYPE $EXTRA_FLAGS"

echo "==> Starting Colima ($VM_TYPE)..."
if colima status 2>/dev/null; then
  echo "    Colima is already running, skipping start."
else
  # Clean up any stale VM from a previous failed attempt
  colima delete --force 2>/dev/null || true

  if ! colima start $COLIMA_FLAGS; then
    echo "    WARNING: Colima failed to start. You can retry manually:"
    echo "      colima delete --force"
    echo "      colima start $COLIMA_FLAGS"
    echo "    Continuing with LaunchAgent installation..."
  fi
fi

echo "==> Installing Colima LaunchAgent..."
mkdir -p "$HOME/Library/LaunchAgents"

# Build ProgramArguments dynamically based on detected VM type
PLIST_ARGS="    <string>${COLIMA_BIN}</string>
    <string>start</string>
    <string>--cpu</string>
    <string>${CPU}</string>
    <string>--memory</string>
    <string>${MEMORY}</string>
    <string>--disk</string>
    <string>${DISK}</string>
    <string>--vm-type</string>
    <string>${VM_TYPE}</string>
    <string>--mount-type</string>
    <string>${MOUNT_TYPE}</string>"

if [ "$VM_TYPE" = "vz" ]; then
  PLIST_ARGS="${PLIST_ARGS}
    <string>--vz-rosetta</string>"
fi

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.colima.autostart</string>
  <key>ProgramArguments</key>
  <array>
${PLIST_ARGS}
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
