# CI Workflow Design

**Goal:** Add a GitHub Actions CI workflow that lints shell scripts and validates the Brewfile.

## Triggers

- Push to `main`
- Pull requests
- Manual dispatch (`workflow_dispatch`)

## Workflow

**File:** `.github/workflows/ci.yml`

**Single job: `check`**
- Runs on `macos-14` (Apple Silicon)
- Steps:
  1. Checkout code
  2. Install shellcheck via Homebrew
  3. Run `shellcheck` on all `.sh` files (`setup.sh`, `scripts/*.sh`)
  4. Run `brew bundle check --file=Brewfile` to validate Brewfile syntax

## Decisions

- **macOS only** — this is a Mac setup project, Ubuntu adds no value
- **No test job** — scripts require interactive input and macOS-specific tools, not suitable for CI simulation
- **No mise/tool manager** — shellcheck via Homebrew is sufficient for this project's needs
- **Single job** — two checks don't warrant separate jobs
