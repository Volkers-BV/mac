#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${HOME}/.nvm"
FNVM_DIR="${HOME}/.fnvm"

# Patch fnvm.sh to replace GNU sed multi-line commands with portable alternatives.
# Upstream fnvm uses `:a;N;$!ba;` which only works with GNU sed, not macOS BSD sed.
patch_fnvm_for_macos() {
  local target="$1"
  python3 - "$target" << 'PYEOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text()

# fnvm_out: strip \r — tr is portable
s = s.replace(
    "sed ':a;N;$!ba;s/'$'\\r''//g'<<<\"$@\"",
    "tr -d '\\r' <<<\"$@\"",
)

# fnvm_safe_find: replace \n with __NEWLINE__ for grep — use awk
s = s.replace(
    "sed ':a;N;$!ba;s/\\n/__NEWLINE__/g'",
    "awk '{if(NR>1)printf \"__NEWLINE__\";printf \"%s\",$0}'",
)

# fnvm_escape_replace: slurp all lines then escape — use awk
s = s.replace(
    r"sed -e ':a; $!{N;ba}' -e 's/[&/\]/\\&/g; s/\n/\\&/g'",
    r"awk '{gsub(/[&\/\\]/,\"\\\\&\");if(NR>1)printf \"\\n\";printf \"%s\",$0}'",
)

# fnvm_replace_file / fnvm_replace: slurp + substitute — use awk-based slurp
s = s.replace(
    "sed -n -e ':a; $!{N;ba}' -e",
    "sed -n -e 'H;${x;s/^\\n//;' -e",
)

p.write_text(s)
PYEOF
}

if ! command -v git &>/dev/null; then
  echo "ERROR: git is not installed. Cannot clone fnvm." >&2
  exit 1
fi

if [ -d "$NVM_DIR" ]; then
  echo "$NVM_DIR already exists, skipping."
else
  echo "==> Creating $NVM_DIR directory..."
  mkdir -p "$NVM_DIR"
  echo "$NVM_DIR created."
fi

if [ -d "$FNVM_DIR" ]; then
  echo "$FNVM_DIR already exists, skipping fnvm install."
else
  echo "==> Cloning fnvm to $FNVM_DIR..."
  if ! git clone https://github.com/qwreey/fnvm.git "$FNVM_DIR" --depth 1; then
    echo "ERROR: Failed to clone fnvm repository." >&2
    exit 1
  fi
  if [ ! -d "$FNVM_DIR/.git" ]; then
    echo "ERROR: fnvm clone appears incomplete — .git directory not found." >&2
    rm -rf "$FNVM_DIR"
    exit 1
  fi
  echo "==> Patching fnvm.sh for macOS compatibility..."
  patch_fnvm_for_macos "$FNVM_DIR/fnvm.sh"
  echo "fnvm installed and patched at $FNVM_DIR."
fi
