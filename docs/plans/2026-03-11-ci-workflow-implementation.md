# CI Workflow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a GitHub Actions CI workflow that runs ShellCheck and validates the Brewfile on every push to main and on PRs.

**Architecture:** Single workflow file with one job. ShellCheck lints all `.sh` files, `brew bundle check` validates Brewfile syntax. Runs on macOS 14 (Apple Silicon).

**Tech Stack:** GitHub Actions, ShellCheck, Homebrew

---

### Task 1: Create CI workflow

**Files:**
- Create: `.github/workflows/ci.yml`

**Step 1: Create the workflow file**

```yaml
name: ci

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  check:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Install shellcheck
        run: brew install shellcheck
      - name: Run shellcheck
        run: shellcheck setup.sh scripts/*.sh
      - name: Validate Brewfile
        run: brew bundle check --file=Brewfile --verbose
```

**Step 2: Verify shellcheck passes locally**

Run: `shellcheck setup.sh scripts/*.sh`
Expected: No errors (we already verified this earlier)

**Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "Add CI workflow with shellcheck and Brewfile validation"
```

---

### Task 2: Push and verify CI runs

**Step 1: Push to remote**

```bash
git push
```

**Step 2: Check CI status**

Run: `gh run list --limit 1`
Expected: A workflow run appears (may be queued or in progress)
