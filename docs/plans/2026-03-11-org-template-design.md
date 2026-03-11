# Design: Organization Template Repo

**Date:** 2026-03-11
**Status:** Approved

## Context

Convert the personal mac-setup repo into an org template at `Volkers-BV/mac`. Developers fork it (or use as GitHub template) and own their copy. Same tech stack across the org: PHP/Laravel, JS/Bun, Zed editor.

## Approach

Minimal cleanup (Approach A): replace hardcoded personal values with prompts or placeholder comments. Keep the repo structure identical. No config framework needed — devs edit files directly in their fork.

## Changes

### 1. Chezmoi config & templates

**`.chezmoi.toml.tmpl`** — add 3 new prompts:

| Prompt | Default | Used in |
|--------|---------|---------|
| `github_user` | `""` | Not used in templates (for dev reference) |
| `editor` | `"zed --wait"` | `dot_gitconfig.tmpl` |
| `languages` | `"en"` | `run_onchange_20` (comma-separated) |

**`bin/setup.sh`** — extract GitHub repo to a variable at the top:
```bash
GITHUB_REPO="${GITHUB_REPO:-Volkers-BV/mac}"
```
Devs change this one line after forking (or set the env var).

**`dot_gitconfig.tmpl`** — replace hardcoded `zed --wait` with `{{ .editor }}`.

**`run_onchange_20-macos-system.sh.tmpl`** — replace hardcoded `"en" "nl"` with template that splits `languages` config into an array.

### 2. Brewfiles & app checklist

**`Brewfile.apps`** — organize into sections:
- Company standard (Chrome, Slack)
- Development tools (Warp, Arc, Zed, Herd, Ray, Tinkerwell, etc.)
- Personal (commented out: Spotify, Setapp, Upscayl, BetterDisplay)

**`run_after_99-summary.sh.tmpl`** — restructure app checks:
- Company-required: FortiClient VPN only (active)
- Recommended via Setapp: Bartender, Paste, CleanShot X, HazeOver, DevUtils, Requestly, AlDente Pro (commented out with instructions)
- Remove hardcoded personal apps from active checks

### 3. README rewrite

Replace personal README with a template guide:
1. Title & generic badges (relative URLs so they work on forks)
2. What's included (brief overview)
3. Getting started (fork, customize, run)
4. What to customize (table pointing to exact files/sections)
5. How it works (keep existing flow diagram)
6. Updating (`chezmoi update`)
7. macOS defaults (keep collapsible sections — already generic)
8. Project structure (keep as-is)
9. CI (keep as-is)

## Files to modify

| File | Action |
|------|--------|
| `.chezmoi.toml.tmpl` | Add `github_user`, `editor`, `languages` prompts |
| `bin/setup.sh` | Replace hardcoded repo with `GITHUB_REPO` variable |
| `dot_gitconfig.tmpl` | Template the editor |
| `.chezmoiscripts/run_onchange_20-macos-system.sh.tmpl` | Template the languages array |
| `brewfiles/Brewfile.apps` | Reorganize into sections with comments |
| `.chezmoiscripts/run_after_99-summary.sh.tmpl` | Restructure app checks |
| `README.md` | Full rewrite as template guide |

## Out of scope

- No Brewfile profiles or config-driven app selection
- No layered override system
- No changes to macOS defaults scripts (already generic)
- No changes to CI workflow logic (just badge URLs)
