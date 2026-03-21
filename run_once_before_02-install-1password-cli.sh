#!/bin/bash
#
# run_once_before_02-install-1password-cli.sh
# ---------------------------------------------
# Installs the 1Password CLI (op) via Homebrew.
# Then verifies it can talk to the 1Password desktop app.
#
# WHY THIS MUST COME BEFORE SCRIPT 03:
#   The Brewfile (script 03) uses `op://` references.
#   If the CLI isn't installed and connected first,
#   chezmoi templates will fail when they try to pull secrets.
#
# PREREQUISITE:
#   The 1Password desktop app must be open and have
#   Settings → Developer → "Integrate with 1Password CLI" turned ON.
#

set -e

# Make sure Homebrew is on PATH (Apple Silicon installs to /opt/homebrew)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo ""
echo "→ [02] 1Password CLI"

# Already installed? Skip straight to the connection check.
if command -v op &>/dev/null; then
    echo "  ✓ Already installed — skipping install"
else
    echo "  Installing via Homebrew..."
    brew install --cask 1password-cli
    echo "  ✓ Installed"
fi

echo ""
echo "  Checking connection to 1Password desktop app..."

if op account list &>/dev/null 2>&1; then
    echo "  ✓ Connected — CLI can reach the desktop app"
else
    echo ""
    echo "  ⚠️  Could not connect to 1Password desktop app."
    echo ""
    echo "  Check all of the following:"
    echo "    1. 1Password desktop app is open"
    echo "    2. Settings → Developer → 'Integrate with 1Password CLI' is ON"
    echo "    3. Settings → Developer → 'Use the SSH Agent' is ON"
    echo "    4. You are signed in to your vault"
    echo ""
    echo "  Then run this to test:"
    echo "    op account list"
    echo ""
    echo "  This script will not block setup, but chezmoi templates"
    echo "  that reference op:// will fail until this is resolved."
fi

echo ""
