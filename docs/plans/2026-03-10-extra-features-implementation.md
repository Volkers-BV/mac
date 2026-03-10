# Extra Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add mackup, enhanced gitconfig with Zed + SSH signing, and Setapp checklist to the mac-setup scripts.

**Architecture:** Extend existing files (Brewfile, configure-git.sh, setup.sh) and add one new config file (config/.gitconfig). No new scripts.

**Tech Stack:** Bash, Homebrew, Git

---

### Task 1: Add mackup to Brewfile

**Files:**
- Modify: `Brewfile`

**Step 1: Add mackup to the formulae section**

Add `brew "mackup"` after the existing formulae in `Brewfile`. Insert after line 11 (`brew "mas"`):

```ruby
brew "mackup"
```

**Step 2: Verify syntax**

Run: `brew bundle check --file=Brewfile 2>&1 | tail -3`
Expected: Either "satisfied" or "can't satisfy" (both confirm parsing works)

**Step 3: Commit**

```bash
git add Brewfile
git commit -m "Add mackup to Brewfile"
```

---

### Task 2: Create config/.gitconfig

**Files:**
- Create: `config/.gitconfig`

**Step 1: Write the gitconfig file**

```ini
[core]
    editor = zed --wait
    commentchar = ;
    ignorecase = false
    excludesfile = ~/.gitignore_global

[init]
    defaultBranch = main

[branch]
    autosetuprebase = always

[push]
    autosetupremote = true
    default = simple

[pull]
    rebase = true
    autostash = true

[fetch]
    prune = true
    prunetags = true

[rebase]
    autosquash = true
    autostash = true

[diff]
    tool = zed

[difftool "zed"]
    cmd = zed --diff \"$LOCAL\" \"$REMOTE\"

[merge]
    tool = zed

[mergetool "zed"]
    cmd = zed --merge \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\"

[gpg]
    format = ssh

[commit]
    gpgsign = true

[tag]
    gpgsign = true
    sort = -taggerdate:iso
```

Note: `user.name`, `user.email`, and `user.signingkey` are NOT in this file — they are set dynamically by `configure-git.sh`.

**Step 2: Commit**

```bash
git add config/.gitconfig
git commit -m "Add gitconfig with sensible defaults, Zed editor, and SSH signing"
```

---

### Task 3: Rewrite scripts/configure-git.sh to use config/.gitconfig

**Files:**
- Modify: `scripts/configure-git.sh`

**Step 1: Replace the entire script**

The new script copies `config/.gitconfig` to `~/.gitconfig`, then sets user-specific values (name, email, signing key) on top.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Configuring Git & SSH..."

# --- SSH key (generate first, needed for git signing) ---
SSH_KEY="${HOME}/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "    SSH key already exists at $SSH_KEY"
else
    read -rp "Enter your email for SSH key: " SSH_EMAIL
    echo "    Generating Ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY"
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

# --- Git config ---
echo "    Installing gitconfig..."
cp "${SCRIPT_DIR}/../config/.gitconfig" "${HOME}/.gitconfig"

read -rp "Enter your full name for git: " GIT_NAME
read -rp "Enter your email for git: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global user.signingkey "${SSH_KEY}.pub"

echo "    Git configured for: $GIT_NAME <$GIT_EMAIL>"
echo "    Commits will be signed with: ${SSH_KEY}.pub"

echo "    Opening GitHub SSH settings..."
open "https://github.com/settings/ssh/new"

echo "==> Git & SSH configuration complete."
echo "    ACTION REQUIRED: Paste your SSH key in the GitHub browser window."
```

**Step 2: Verify shellcheck passes**

Run: `shellcheck scripts/configure-git.sh`
Expected: No errors

**Step 3: Commit**

```bash
git add scripts/configure-git.sh
git commit -m "Rewrite configure-git.sh to use shipped gitconfig with Zed and SSH signing"
```

---

### Task 4: Update setup.sh with mackup reminder and Setapp checklist

**Files:**
- Modify: `setup.sh`

**Step 1: Replace the summary section (lines 67-87)**

Replace everything from `# Summary` to the end of file with:

```bash
# Summary
echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "  Installed via Brew:  $(brew list --formula | wc -l | tr -d ' ') formulae, $(brew list --cask | wc -l | tr -d ' ') casks"
echo "  macOS defaults:      Applied"
echo "  Git:                 $(git config --global user.name) <$(git config --global user.email)>"
echo "  SSH key:             ~/.ssh/id_ed25519"
echo ""
echo "  Manual actions remaining:"
echo "  - Install FortiClient VPN from browser download"
echo "  - Add SSH key to GitHub (should be in clipboard)"
echo "  - Run 'mackup restore' to restore app settings from iCloud"
echo "  - Sign in to apps (Spotify, Slack, Arc, Chrome, etc.)"
echo "  - Restart Mac to apply all settings"
echo ""
echo "  Setapp apps to install:"
echo "  - Bartender"
echo "  - Paste"
echo "  - CleanShot"
echo "  - HazeOver"
echo "  - DevUtils"
echo "  - Requestly"
echo "  - AlDente Pro"
echo ""
echo "  To re-run a specific step, delete the line from .setup-completed-steps"
echo "  and run this script again."
echo ""
```

**Step 2: Verify shellcheck passes**

Run: `shellcheck setup.sh`
Expected: No errors

**Step 3: Commit**

```bash
git add setup.sh
git commit -m "Add mackup restore reminder and Setapp checklist to setup summary"
```

---

### Task 5: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Update the "What It Does" and "Apps Installed" sections**

Add mackup to the CLI list. Add a Setapp section. Mention git signing.

In the **CLI** line, add `mackup`:
```
**CLI:** git, gh, composer, bun, nvm, yarn, mas, mackup
```

After the **GUI** line, add:
```

**Setapp:** Bartender, Paste, CleanShot, HazeOver, DevUtils, Requestly, AlDente Pro
```

In "What It Does" item 4, change to:
```
4. Configures Git with Ed25519 SSH key + commit signing, Zed as editor
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "Update README with mackup, Setapp apps, and git signing"
```
