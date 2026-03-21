#!/bin/bash
#
# run_once_before_01-install-homebrew.sh
# ----------------------------------------
# Installs Homebrew if it isn't already present.
#
# chezmoi runs this exactly once (tracked by hash).
# Safe to re-run manually — the check at the top makes it idempotent.
#
# Runs BEFORE dotfiles are applied (the "before_" prefix).
# Must succeed before script 02 and 03 run.
#

set -e  # Stop on any error

echo ""
echo "→ [01] Homebrew"

# Already installed? Nothing to do.
if command -v brew &>/dev/null; then
    echo "  ✓ Already installed — skipping"
    exit 0
fi

echo "  Installing Homebrew..."
echo "  (You may be prompted for your Mac password)"
echo ""

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# On Apple Silicon, Homebrew installs to /opt/homebrew.
# Make it available to the rest of this script immediately.
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo ""
echo "  ✓ Homebrew installed"
