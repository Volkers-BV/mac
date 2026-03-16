#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${HOME}/.nvm"
FNVM_DIR="${HOME}/.fnvm"

if ! command -v git &>/dev/null; then
  echo "ERROR: git is not installed. Cannot clone fnvm." >&2
  exit 1
fi

if [ -d "$NVM_DIR" ]; then
  echo "$NVM_DIR already exists, skipping."
else
  echo "==> Creating $NVM_DIR directory..."
  mkdir -p "$NVM_DIR"
  echo "$NVM_DIR created."
fi

if [ -d "$FNVM_DIR" ]; then
  echo "$FNVM_DIR already exists, skipping fnvm install."
else
  echo "==> Cloning fnvm to $FNVM_DIR..."
  if ! git clone https://github.com/qwreey/fnvm.git "$FNVM_DIR" --depth 1; then
    echo "ERROR: Failed to clone fnvm repository." >&2
    exit 1
  fi
  if [ ! -d "$FNVM_DIR/.git" ]; then
    echo "ERROR: fnvm clone appears incomplete — .git directory not found." >&2
    rm -rf "$FNVM_DIR"
    exit 1
  fi
  echo "fnvm installed at $FNVM_DIR."
fi
