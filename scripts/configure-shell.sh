#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring shell..."

ZSHRC="${HOME}/.zshrc"

# Back up existing .zshrc if present
if [ -f "$ZSHRC" ]; then
    cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    echo "    Backed up existing .zshrc"
fi

cat > "$ZSHRC" <<'ZSHRC_CONTENT'
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Composer global binaries
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Yarn global binaries
export PATH="$HOME/.yarn/bin:$PATH"
ZSHRC_CONTENT

echo "==> Shell configuration complete."
echo "    Written to $ZSHRC"
