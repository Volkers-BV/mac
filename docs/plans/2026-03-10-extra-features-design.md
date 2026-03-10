# Extra Features Design

**Goal:** Extend the existing mac-setup scripts with mackup, enhanced gitconfig, and Setapp checklist.

## Changes

### 1. Mackup

- Add `mackup` to `Brewfile`
- Add "run `mackup restore`" reminder to `setup.sh` summary
- No config file or auto-run (restore is destructive, should be intentional)

### 2. Gitconfig

Ship `config/.gitconfig` with sensible defaults. `configure-git.sh` copies it to `~/.gitconfig` then sets user.name/email on top.

Settings:
- **Editor:** Zed (`zed --wait`)
- **Diff/merge tool:** Zed
- **Core:** `commentchar = ;`, `ignorecase = false`, `excludesfile = ~/.gitignore_global`
- **Branch:** `autosetuprebase = always`
- **Push:** `autosetupremote = true`, `default = simple`
- **Pull:** `rebase = true`, `autostash = true`
- **Fetch:** `prune = true`, `prunetags = true`
- **Rebase:** `autosquash = true`, `autostash = true`
- **Init:** `defaultBranch = main`
- **GPG signing via SSH:** `gpg.format = ssh`, `user.signingkey = ~/.ssh/id_ed25519.pub`, `commit.gpgsign = true`, `tag.gpgsign = true`
- **Drop:** SourceTree difftool/mergetool references, nano editor

### 3. Setapp Checklist

Add Setapp apps to `setup.sh` summary output:
- Bartender, Paste, CleanShot, HazeOver, DevUtils, Requestly, AlDente Pro

### 4. No bash config

Warp runs zsh. Only `.zshrc` needed. No `bash_profile` or `bashrc`.

## Files Affected

| Change | Files |
|--------|-------|
| Mackup in Brewfile | `Brewfile` |
| Mackup reminder | `setup.sh` |
| Gitconfig with defaults | New: `config/.gitconfig`, modify: `scripts/configure-git.sh` |
| Setapp checklist | `setup.sh` |
