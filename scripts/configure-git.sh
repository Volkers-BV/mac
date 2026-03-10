#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring Git & SSH..."

# --- Git config ---
read -rp "Enter your full name for git: " GIT_NAME
read -rp "Enter your email for git: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true

echo "    Git configured for: $GIT_NAME <$GIT_EMAIL>"

# --- SSH key ---
SSH_KEY="${HOME}/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "    SSH key already exists at $SSH_KEY"
else
    echo "    Generating Ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)"

# Create SSH config if it doesn't exist
SSH_CONFIG="${HOME}/.ssh/config"
if [ ! -f "$SSH_CONFIG" ] || ! grep -q "IdentityFile.*id_ed25519" "$SSH_CONFIG"; then
    cat >> "$SSH_CONFIG" <<EOF

Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
    echo "    SSH config updated."
fi

ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY"

# Copy public key to clipboard
pbcopy < "${SSH_KEY}.pub"
echo "    Public key copied to clipboard."

echo "    Opening GitHub SSH settings..."
open "https://github.com/settings/ssh/new"

echo "==> Git & SSH configuration complete."
echo "    ACTION REQUIRED: Paste your SSH key in the GitHub browser window."
