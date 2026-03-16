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
| macOS defaults | `.chezmoiscripts/run_onchange_20-28*` | Edit any preferences |

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

<details>
<summary>Energy (Apple Silicon power management)</summary>

- Battery: display sleep after 15 minutes
- AC power: display and system sleep disabled (never)
- Low Power Mode on battery (efficiency cores only), full performance on AC
- Power Nap disabled on battery, enabled on AC
- Proximity wake disabled (no wake from nearby iPhone/Apple Watch)
- TCP keepalive enabled during sleep (email, VPN, SSH stay connected)

</details>

<details>
<summary>Performance (animations, app lifecycle)</summary>

- Disables window opening/closing animations
- Instant Quick Look panel (no fade-in delay)
- Faster Dock auto-hide and reveal (no delay)
- Prevents macOS from auto-terminating inactive apps
- Disables window restore when re-opening apps

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
│   ├── run_once_02-configure-fnvm.sh             # Create ~/.nvm and clone fnvm to ~/.fnvm
│   ├── run_onchange_10-install-packages.sh.tmpl
│   ├── run_onchange_11-install-node.sh           # Install latest LTS + latest Node via nvm; create ~/.nvmrc.default
│   ├── run_onchange_20-macos-system.sh.tmpl
│   ├── run_onchange_21-macos-dock.sh.tmpl
│   ├── run_onchange_22-macos-finder.sh.tmpl
│   ├── run_onchange_23-macos-input.sh.tmpl
│   ├── run_onchange_24-macos-safari.sh.tmpl
│   ├── run_onchange_25-macos-apps.sh.tmpl
│   ├── run_onchange_26-macos-screenshots.sh.tmpl
│   ├── run_onchange_27-macos-energy.sh.tmpl
│   ├── run_onchange_28-macos-performance.sh.tmpl
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
       ├─ run_once_02  → Create ~/.nvm directory; clone fnvm to ~/.fnvm
       ├─ run_onchange_10 → brew update && brew bundle (core → dev → apps → office → quicklook)
       ├─ run_onchange_20-28 → Apply macOS defaults (system, dock, finder, input, safari, apps, screenshots, energy, performance)
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
