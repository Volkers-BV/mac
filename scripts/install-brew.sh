#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "    Waiting for Xcode CLI Tools installation..."
    echo "    Please complete the installation dialog, then press Enter."
    read -r
else
    echo "    Xcode CLI Tools already installed."
fi

# Accept Xcode license
sudo xcodebuild -license accept 2>/dev/null || true

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session (Apple Silicon path)
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "    Homebrew already installed."
fi

echo "==> Updating Homebrew..."
brew update

echo "==> Installing packages from Brewfile..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
brew bundle --file="${SCRIPT_DIR}/../Brewfile" --no-lock

echo "==> Brew installation complete."
