#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${HOME}/.nvm"

# Locate Homebrew prefix (handles Apple Silicon and Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  BREW_PREFIX="/opt/homebrew"
elif [ -x /usr/local/bin/brew ]; then
  BREW_PREFIX="/usr/local"
else
  echo "ERROR: Homebrew not found. Run the package installation step first."
  exit 1
fi

NVM_SH="${BREW_PREFIX}/opt/nvm/nvm.sh"
if [ ! -s "$NVM_SH" ]; then
  echo "ERROR: nvm not found at ${NVM_SH}. Make sure nvm is installed via Homebrew."
  exit 1
fi

# Source nvm so its commands are available in this session
export NVM_DIR
# shellcheck source=/dev/null
source "$NVM_SH"

# Create a symlink at $NVM_DIR/nvm.sh so fnvm_init can find nvm.sh at the
# expected path ($NVM_DIR/nvm.sh) even though nvm is installed via Homebrew.
NVM_SH_LINK="${NVM_DIR}/nvm.sh"
if [ ! -L "$NVM_SH_LINK" ]; then
  echo "==> Creating nvm.sh symlink for fnvm compatibility..."
  ln -sf "$NVM_SH" "$NVM_SH_LINK"
  echo "    ${NVM_SH_LINK} -> ${NVM_SH}"
fi

echo "==> Installing latest LTS Node.js..."
nvm install --lts

echo "==> Installing latest Node.js..."
nvm install node

echo "==> Setting default Node.js version to latest LTS..."
nvm alias default 'lts/*'

echo "==> Creating ~/.nvmrc.default for fnvm auto-switching..."
nvm version 'lts/*' > "${HOME}/.nvmrc.default"
echo "    Default version: $(cat "${HOME}/.nvmrc.default")"

echo "==> Node.js installation complete."
