#!/bin/bash
#
# run_once_before_03-install-packages.sh
# ----------------------------------------
# Runs `brew bundle` against the Brewfile in the chezmoi source directory.
# This installs all CLI tools, apps, and fonts in one shot.
#
# WHY brew bundle INSTEAD OF individual brew install lines:
#   - The Brewfile is version-controlled — you can see exactly what's installed
#   - `brew bundle check` can tell you if anything is missing
#   - `brew bundle cleanup` can remove things no longer in the list
#   - It's the standard Homebrew way to manage a full machine setup
#
# NOTE: If a cask app is already installed (e.g. you installed iTerm2 manually),
# Homebrew will detect this and skip it — no reinstall, no error.
#

set -e

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo ""
echo "→ [03] Installing packages from Brewfile"

BREWFILE="${HOME}/.local/share/chezmoi/Brewfile"

if [[ ! -f "${BREWFILE}" ]]; then
    echo "  ⚠️  Brewfile not found at: ${BREWFILE}"
    echo "  Skipping — make sure the Brewfile is committed to your dotfiles repo."
    exit 1
fi

echo "  Using: ${BREWFILE}"
echo ""

brew bundle --file="${BREWFILE}"

echo ""
echo "  ✓ All packages installed"
echo ""
echo "  Manual installs still needed:"
echo "    • Kiro (AWS AI IDE) — not on Homebrew yet"
echo "      https://kiro.dev"
echo ""
