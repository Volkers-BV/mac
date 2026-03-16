#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${HOME}/.nvm"
FNVM_DIR="${HOME}/.fnvm"

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
  git clone https://github.com/qwreey/fnvm.git "$FNVM_DIR" --depth 1
  echo "fnvm installed at $FNVM_DIR."
fi
