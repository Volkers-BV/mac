#!/usr/bin/env bash
set -euo pipefail

# --- Resolve repo root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verify we're in the right repo
if [[ ! -f "$REPO_ROOT/bin/setup.sh" ]]; then
  echo "ERROR: Cannot find bin/setup.sh. Run this script from the repo root or bin/ directory."
  exit 1
fi

echo ""
echo "============================================"
echo "  Personalize your Mac setup fork"
echo "============================================"
echo ""

CHANGES=()

# =============================================================================
# 1. GitHub repo URL
# =============================================================================
SETUP_FILE="$REPO_ROOT/bin/setup.sh"
CURRENT_REPO=$(sed -n 's/.*GITHUB_REPO:-\([^}]*\)}.*/\1/p' "$SETUP_FILE")

echo "--- GitHub repo URL ---"
echo "Current: $CURRENT_REPO"
read -rp "Enter your GitHub owner/repo (or press Enter to keep current): " NEW_REPO

if [[ -n "$NEW_REPO" && "$NEW_REPO" != "$CURRENT_REPO" ]]; then
  # Escape slashes for sed
  ESCAPED_OLD=$(printf '%s' "$CURRENT_REPO" | sed 's/[\/&]/\\&/g')
  ESCAPED_NEW=$(printf '%s' "$NEW_REPO" | sed 's/[\/&]/\\&/g')
  sed -i '' "s/GITHUB_REPO:-${ESCAPED_OLD}/GITHUB_REPO:-${ESCAPED_NEW}/" "$SETUP_FILE"
  CHANGES+=("Updated GITHUB_REPO: $CURRENT_REPO -> $NEW_REPO")
  echo "  Updated."
else
  echo "  Kept as-is."
fi
echo ""

# =============================================================================
# 2. App selection (Brewfile.apps)
# =============================================================================
APPS_FILE="$REPO_ROOT/brewfiles/Brewfile.apps"

echo "--- App selection (brewfiles/Brewfile.apps) ---"
echo "Toggle apps on/off. Currently enabled apps are shown with [ON], disabled with [OFF]."
echo ""

# Read file into array, preserving comments and blank lines
mapfile -t LINES < "$APPS_FILE"
MODIFIED_APPS=false

for i in "${!LINES[@]}"; do
  LINE="${LINES[$i]}"

  # Skip blank lines and section comment headers (lines starting with # === or just #)
  # We only care about lines that contain a cask/brew entry
  if [[ "$LINE" =~ ^[[:space:]]*#[[:space:]]*(cask|brew|mas)[[:space:]] ]]; then
    # Commented-out package line — strip leading "# "
    UNCOMMENTED="${LINE#\#}"       # remove leading #
    UNCOMMENTED="${UNCOMMENTED# }" # remove single leading space if present
    printf "  [OFF] %-40s  Enable? (y/N): " "$UNCOMMENTED"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
      LINES[i]="$UNCOMMENTED"
      MODIFIED_APPS=true
    fi
  elif [[ "$LINE" =~ ^[[:space:]]*(cask|brew|mas)[[:space:]] ]]; then
    # Active package line
    printf "  [ON]  %-40s  Disable? (y/N): " "$LINE"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
      LINES[i]="# $LINE"
      MODIFIED_APPS=true
    fi
  fi
  # Skip pure comment lines (section headers) and blank lines
done

if [[ "$MODIFIED_APPS" == true ]]; then
  printf '%s\n' "${LINES[@]}" > "$APPS_FILE"
  CHANGES+=("Updated app selection in brewfiles/Brewfile.apps")
  echo ""
  echo "  App selection updated."
else
  echo ""
  echo "  No changes to apps."
fi
echo ""

# =============================================================================
# 3. Brewfile categories (docker, office)
# =============================================================================
INSTALL_SCRIPT="$REPO_ROOT/.chezmoiscripts/run_onchange_10-install-packages.sh.tmpl"

echo "--- Brewfile categories ---"
echo "Optionally disable entire Brewfile categories."
echo ""

disable_brewfile_category() {
  local category="$1"
  local display_name="$2"
  local brewfile_name="Brewfile.${category}"

  # Check if already disabled (line is commented out in BREWFILES array)
  if grep -q "^[[:space:]]*#.*${brewfile_name}" "$INSTALL_SCRIPT"; then
    printf "  [OFF] %-20s  Enable? (y/N): " "$display_name"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
      # Uncomment the BREWFILES array entry
      sed -i '' "s|^[[:space:]]*#[[:space:]]*\(.*${brewfile_name}.*\)|\1|" "$INSTALL_SCRIPT"
      # Uncomment the hash line
      sed -i '' "s|^# ${category}:.*|# ${category}:      {{ include \"brewfiles/${brewfile_name}\" | sha256sum }}|" "$INSTALL_SCRIPT"
      CHANGES+=("Enabled Brewfile category: $display_name")
      echo "    Enabled."
    fi
  else
    printf "  [ON]  %-20s  Disable? (y/N): " "$display_name"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
      # Comment out the BREWFILES array entry
      sed -i '' "/${brewfile_name}/s|^[[:space:]]*\"\(.*\)\"|  # \"\1\"|" "$INSTALL_SCRIPT"
      # Comment out the hash line (replace with static comment so chezmoi doesn't error)
      sed -i '' "s|^# ${category}:.*|# ${category}: (disabled)|" "$INSTALL_SCRIPT"
      CHANGES+=("Disabled Brewfile category: $display_name")
      echo "    Disabled."
    fi
  fi
}

disable_brewfile_category "docker" "Docker tools"
disable_brewfile_category "office" "Office suite"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo "============================================"
echo "  Summary"
echo "============================================"
echo ""

if [[ ${#CHANGES[@]} -eq 0 ]]; then
  echo "No changes were made."
else
  echo "Changes made:"
  for change in "${CHANGES[@]}"; do
    echo "  - $change"
  done
  echo ""

  OWNER="${NEW_REPO:-$CURRENT_REPO}"
  OWNER="${OWNER%%/*}"

  echo "Next steps:"
  echo "  1. Review the changes:  git diff"
  echo "  2. Commit your fork:    git add -A && git commit -m \"Personalize for ${OWNER}\""
  echo "  3. Run setup:           ./bin/setup.sh"
fi
echo ""
