# Org Template Conversion — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert the personal mac-setup repo into an org template at `Volkers-BV/mac` that developers fork and customize.

**Architecture:** Minimal cleanup — replace hardcoded personal values with chezmoi prompts or configurable variables, reorganize Brewfiles and app checklists with clear section comments, rewrite README as a template guide.

**Tech Stack:** chezmoi templates (Go text/template), bash, Homebrew Brewfiles

---

### Task 1: Add new prompts to `.chezmoi.toml.tmpl`

**Files:**
- Modify: `.chezmoi.toml.tmpl`
- Modify: `.github/test-chezmoi-data.toml`

**Step 1: Add `editor` and `languages` prompts to `.chezmoi.toml.tmpl`**

Replace full file with:

```
{{- $name := promptStringOnce . "name" "Full name" -}}
{{- $email := promptStringOnce . "email" "Email address" -}}
{{- $hostname := promptStringOnce . "hostname" "Computer hostname" -}}
{{- $locale := promptStringOnce . "locale" "Locale" "en_US@currency=EUR" -}}
{{- $editor := promptStringOnce . "editor" "Git editor command" "zed --wait" -}}
{{- $languages := promptStringOnce . "languages" "Languages (comma-separated, e.g. en,nl)" "en" -}}

[data]
  name = {{ $name | quote }}
  email = {{ $email | quote }}
  hostname = {{ $hostname | quote }}
  locale = {{ $locale | quote }}
  editor = {{ $editor | quote }}
  languages = {{ $languages | quote }}
```

**Step 2: Update test data to include new fields**

Replace full file `.github/test-chezmoi-data.toml` with:

```toml
[data]
  name = "Test User"
  email = "test@example.com"
  hostname = "Test-Mac"
  locale = "en_US"
  editor = "zed --wait"
  languages = "en"
```

**Step 3: Run chezmoi verify to confirm templates still work**

Run: `chezmoi apply --source="$(pwd)" --config=.github/test-chezmoi-data.toml --no-tty --dry-run --verbose 2>&1 | head -20`
Expected: no template errors

**Step 4: Commit**

```bash
git add .chezmoi.toml.tmpl .github/test-chezmoi-data.toml
git commit -m "Add editor and languages prompts to chezmoi config"
```

---

### Task 2: Template the git editor in `dot_gitconfig.tmpl`

**Files:**
- Modify: `dot_gitconfig.tmpl`

**Step 1: Replace hardcoded editor with template variable**

In `dot_gitconfig.tmpl`, replace line 7:
```
	editor = zed --wait
```
with:
```
	editor = {{ .editor }}
```

Also replace the difftool and mergetool sections (lines 34-44) to derive the tool name from the editor. Since all devs use Zed and this is fork-and-own, keep the Zed-specific difftool/mergetool config as-is — devs can change it in their fork.

**Step 2: Run chezmoi verify**

Run: `chezmoi apply --source="$(pwd)" --config=.github/test-chezmoi-data.toml --no-tty --dry-run --verbose 2>&1 | grep -i "error"`
Expected: no output (no errors)

**Step 3: Commit**

```bash
git add dot_gitconfig.tmpl
git commit -m "Template git editor from chezmoi config"
```

---

### Task 3: Template the languages array in system defaults

**Files:**
- Modify: `.chezmoiscripts/run_onchange_20-macos-system.sh.tmpl`

**Step 1: Replace hardcoded language array**

In `run_onchange_20-macos-system.sh.tmpl`, replace line 65:
```bash
defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
```
with:
```bash
defaults write NSGlobalDomain AppleLanguages -array{{ range split "," .languages }} "{{ . }}"{{ end }}
```

This splits the comma-separated `languages` config value (e.g. `"en,nl"`) into `-array "en" "nl"`.

**Step 2: Run chezmoi verify**

Run: `chezmoi apply --source="$(pwd)" --config=.github/test-chezmoi-data.toml --no-tty --dry-run --verbose 2>&1 | grep -i "error"`
Expected: no output (no errors)

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_onchange_20-macos-system.sh.tmpl
git commit -m "Template languages array from chezmoi config"
```

---

### Task 4: Extract GitHub repo variable in `bin/setup.sh`

**Files:**
- Modify: `bin/setup.sh`

**Step 1: Add `GITHUB_REPO` variable and use it**

After the shebang and `set -euo pipefail` (line 2), add:
```bash

# --- Configuration ---
# After forking, update this to point to your fork.
GITHUB_REPO="${GITHUB_REPO:-Volkers-BV/mac}"
```

Replace line 86:
```bash
  chezmoi init --apply fridzema/dotfiles-setup
```
with:
```bash
  chezmoi init --apply "$GITHUB_REPO"
```

**Step 2: Verify script syntax**

Run: `bash -n bin/setup.sh`
Expected: no output (no syntax errors)

**Step 3: Commit**

```bash
git add bin/setup.sh
git commit -m "Extract GitHub repo to configurable variable in setup.sh"
```

---

### Task 5: Reorganize `Brewfile.apps` into sections

**Files:**
- Modify: `brewfiles/Brewfile.apps`

**Step 1: Replace full file with organized sections**

```ruby
# === Company standard ===
cask "google-chrome"
cask "slack"

# === Development tools ===
cask "warp"
cask "arc"
cask "zed"
cask "github"
cask "herd"
cask "ray"
cask "tinkerwell"
cask "imageoptim"

# === Personal (uncomment or add your own) ===
# cask "spotify"
# cask "setapp"
# cask "upscayl"
# cask "betterdisplay"
```

**Step 2: Validate Brewfile**

Run: `brew bundle list --file=brewfiles/Brewfile.apps > /dev/null && echo "OK"`
Expected: `OK`

**Step 3: Commit**

```bash
git add brewfiles/Brewfile.apps
git commit -m "Reorganize Brewfile.apps into company, dev, and personal sections"
```

---

### Task 6: Restructure app checklist in summary script

**Files:**
- Modify: `.chezmoiscripts/run_after_99-summary.sh.tmpl`

**Step 1: Replace the app inventory section (lines 41-63)**

Replace lines 41–63 (from `# --- Manual-install app inventory ---` through the closing `fi`) with:

```bash
# --- Manual-install app inventory ---
# Update this list when apps are added, removed, or renamed.

# Company-required
check_app "FortiClient VPN" "/Applications/FortiClient.app"

# Recommended (via Setapp) — uncomment any you use:
# check_app "Bartender" "/Applications/Bartender 4.app"
# check_app "Paste" "/Applications/Paste.app"
# check_app "CleanShot X" "/Applications/CleanShot X.app"
# check_app "HazeOver" "/Applications/HazeOver.app"
# check_app "DevUtils" "/Applications/DevUtils.app"
# check_app "Requestly" "/Applications/Requestly.app"
# check_app "AlDente Pro" "/Applications/AlDente Pro.app"

# Add your own checks below:


if [ ${#MISSING[@]} -gt 0 ]; then
  echo "  Apps not yet installed:"
  for app in "${MISSING[@]}"; do
    echo "    - $app"
  done
else
  echo "  All expected apps are installed."
fi
```

**Step 2: Verify template syntax**

Run: `sed 's/{{[^}]*}}/TMPL/g' .chezmoiscripts/run_after_99-summary.sh.tmpl | shellcheck --exclude=SC1091 -`
Expected: no errors (warnings about MISSING array are OK)

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_after_99-summary.sh.tmpl
git commit -m "Restructure app checklist: company-required + recommended"
```

---

### Task 7: Rewrite README as template guide

**Files:**
- Modify: `README.md`

**Step 1: Replace full README**

Write a new README with these sections (content below):

```markdown
# Mac Setup

Opinionated Mac development environment setup, managed with [chezmoi](https://chezmoi.io).

Fork this repo and make it yours.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue)
![chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-blue)

---

## What's included

- Homebrew packages (CLI tools, dev tools, GUI apps, office, QuickLook plugins)
- Dotfiles: `.gitconfig`, `.zshrc`, `.ssh/config`, `.gitignore_global`
- macOS system defaults (dark mode, Dock, Finder, keyboard, Safari, and more)
- Ed25519 SSH key generation with macOS Keychain integration
- Optional app settings sync via Mackup + iCloud

---

## Getting started

### 1. Fork this repo

Click **"Use this template"** or **Fork** on GitHub to create your own copy.

### 2. Customize

Before running, review and edit these files in your fork:

| What | File | Look for |
|------|------|----------|
| Setup script repo URL | `bin/setup.sh` | `GITHUB_REPO` variable at top |
| Brew apps | `brewfiles/Brewfile.apps` | Sections: company, dev, personal |
| App install checklist | `.chezmoiscripts/run_after_99-summary.sh.tmpl` | Uncomment apps you use |
| macOS defaults | `.chezmoiscripts/run_onchange_20-25*` | Edit any preferences |

On first run, chezmoi will prompt you for: name, email, hostname, locale, editor, and languages.

### 3. Run on a fresh Mac

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<your-user>/mac/main/bin/setup.sh)"
```

Or clone and run locally:

```bash
git clone https://github.com/<your-user>/mac.git
cd mac
./bin/setup.sh
```

This installs Xcode CLI Tools, Homebrew, and chezmoi, then runs `chezmoi init --apply` which:

1. Prompts for your name, email, hostname, locale, editor, and languages
2. Generates an SSH key and adds it to the macOS Keychain
3. Deploys dotfiles
4. Installs Homebrew packages
5. Applies macOS system defaults
6. Prints a summary with next steps

---

## Updating

After editing any file in your fork:

```bash
chezmoi update    # git pull + apply in one step
```

Or apply without pulling:

```bash
chezmoi apply
```

Scripts prefixed with `run_onchange_` only re-run when their content changes.

---

## App settings sync (optional)

[Mackup](https://github.com/lra/mackup) can back up and restore app settings via iCloud.

**Start using it** — on a machine that's already configured:

```bash
mackup backup       # copies app configs to iCloud, replaces with symlinks
```

On a fresh machine after setup:

```bash
mackup restore      # pulls configs from iCloud, symlinks into place
```

Mackup is installed via Homebrew but completely optional.

---

## What gets configured

<details>
<summary>System (hostname, appearance, locale, security)</summary>

- Sets computer name via `scutil` and NetBIOS
- Enables dark mode with graphite accent color
- Disables startup sound
- Shows IP/hostname/OS on the login window
- Expands save and print panels by default
- Saves to disk (not iCloud) by default
- Sets metric units (Centimeters) and Celsius
- Configures locale, languages, and clock format
- Disables natural scrolling
- Requires password immediately after sleep/screen saver

</details>

<details>
<summary>Dock (layout, size, animations)</summary>

- Sets icon size to 36px
- Minimizes windows into their app icon
- Wipes default app icons for a clean Dock
- Hides recent applications
- Disables Dashboard and auto-rearrange Spaces
- Sets Mission Control animation speed to 0.1s
- Disables launch animation

</details>

<details>
<summary>Finder (file visibility, views, behavior)</summary>

- Shows hidden files and all file extensions
- Enables status bar and path bar
- Defaults to list view and searches current folder
- Opens new windows at Desktop
- Sorts folders before files
- Disables extension-change warnings
- Prevents .DS_Store on network and USB drives
- Unhides ~/Library

</details>

<details>
<summary>Input (keyboard, trackpad, Bluetooth)</summary>

- Maximum key repeat rate (1) with fast initial delay (10)
- Disables press-and-hold in favor of key repeat
- Disables natural scrolling
- Turns off auto-capitalization, smart dashes, smart quotes, auto-correct, and period substitution
- Enables full keyboard access (Tab through all controls)
- Improves Bluetooth audio quality (Apple Bitpool Min: 40)

</details>

<details>
<summary>Safari (privacy, developer tools)</summary>

- Stops sending search queries to Apple
- Suppresses search suggestions
- Shows full URL in the address bar
- Sets home page to `about:blank`
- Enables Develop menu and Web Inspector
- Warns about fraudulent websites
- Auto-updates extensions

</details>

<details>
<summary>Apps (App Store, TextEdit, Photos, Terminal, Activity Monitor)</summary>

- App Store: daily update check, auto-download, auto-install critical and app updates
- TextEdit: plain text mode, UTF-8 encoding
- Photos: no auto-open when devices are plugged in
- Time Machine: no prompt for new backup disks
- Terminal: UTF-8 only
- Activity Monitor: shows all processes sorted by CPU usage

</details>

---

## Project structure

```
.
├── bin/
│   └── setup.sh                          # Bootstrap: Xcode CLI Tools, Homebrew, chezmoi
├── brewfiles/
│   ├── Brewfile.core                     # git, gh, mas, mackup
│   ├── Brewfile.dev                      # composer, bun, nvm, yarn
│   ├── Brewfile.apps                     # warp, arc, zed, slack, spotify, ...
│   ├── Brewfile.office                   # microsoft-office
│   └── Brewfile.quicklook               # qlmarkdown, quicklook-json
├── .chezmoiscripts/
│   ├── run_onchange_00-preflight.sh.tmpl
│   ├── run_once_01-generate-ssh-key.sh.tmpl
│   ├── run_once_02-configure-nvm.sh
│   ├── run_onchange_10-install-packages.sh.tmpl
│   ├── run_onchange_20-macos-system.sh.tmpl
│   ├── run_onchange_21-macos-dock.sh.tmpl
│   ├── run_onchange_22-macos-finder.sh.tmpl
│   ├── run_onchange_23-macos-input.sh.tmpl
│   ├── run_onchange_24-macos-safari.sh.tmpl
│   ├── run_onchange_25-macos-apps.sh.tmpl
│   └── run_after_99-summary.sh.tmpl
├── helpers/
│   └── macos-defaults.sh                 # Shared library: set_default, require_sudo, restart_app
├── .chezmoi.toml.tmpl                    # Prompts for name, email, hostname, locale, editor, languages
├── dot_gitconfig.tmpl
├── dot_zshrc
├── dot_gitignore_global
├── private_dot_ssh/
│   └── config.tmpl
└── .github/
    ├── workflows/ci.yml                  # ShellCheck + chezmoi verify + Brewfile lint
    └── test-chezmoi-data.toml            # CI test fixture
```

---

## How it works

```
bin/setup.sh
  │
  ├─ Install Xcode CLI Tools (if missing)
  ├─ Install Homebrew (Apple Silicon or Intel)
  ├─ Install chezmoi
  └─ chezmoi init --apply
       │
       ├─ Prompt for name, email, hostname, locale, editor, languages
       ├─ run_onchange_00 → Preflight: cache sudo, check Full Disk Access
       ├─ run_once_01  → Generate Ed25519 SSH key, add to Keychain, copy pub to clipboard
       ├─ run_once_02  → Create ~/.nvm directory
       ├─ run_onchange_10 → brew update && brew bundle (core → dev → apps → office → quicklook)
       ├─ run_onchange_20-25 → Apply macOS defaults (system, dock, finder, input, safari, apps)
       ├─ Deploy templates → ~/.gitconfig, ~/.zshrc, ~/.ssh/config, ~/.gitignore_global
       └─ run_after_99 → Print summary (installed count, missing apps, next steps)
```

---

## CI

Every push and PR runs three checks on macOS 14:

| Job | What it does |
|-----|--------------|
| shellcheck | Lints all shell scripts (pure and templated) |
| chezmoi-verify | Dry-run `chezmoi apply` with test data to validate templates |
| brewfile-lint | Runs `brew bundle list` on each Brewfile to verify package references |

---

## Manual steps

The summary script tells you what's left after setup:

- Add your SSH public key to [github.com/settings/keys](https://github.com/settings/keys) (it's already in your clipboard)
- Install FortiClient VPN from [fortinet.com](https://www.fortinet.com/support/product-downloads#vpn)
- Optionally install recommended Setapp apps
- Restart — some macOS defaults only take effect after a reboot

---

## License

[MIT](LICENSE)
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "Rewrite README as org template guide"
```

---

### Task 8: Run full CI checks locally

**Files:** none (verification only)

**Step 1: Run shellcheck on pure scripts**

Run: `shellcheck bin/setup.sh helpers/macos-defaults.sh .chezmoiscripts/run_once_02-configure-nvm.sh && echo "OK"`
Expected: `OK`

**Step 2: Run shellcheck on templated scripts**

Run: `for f in $(find .chezmoiscripts -name '*.sh.tmpl'); do sed 's/{{[^}]*}}/TMPL/g' "$f" | shellcheck --exclude=SC1091 - || exit 1; done && echo "OK"`
Expected: `OK`

**Step 3: Run chezmoi verify**

Run: `chezmoi apply --source="$(pwd)" --config=.github/test-chezmoi-data.toml --no-tty --dry-run --verbose 2>&1 | grep -i "error"`
Expected: no output

**Step 4: Validate all Brewfiles**

Run: `for f in brewfiles/Brewfile.*; do brew bundle list --file="$f" > /dev/null || exit 1; done && echo "OK"`
Expected: `OK`
