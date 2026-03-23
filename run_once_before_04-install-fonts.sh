#!/bin/bash
#
# run_once_before_04-install-fonts.sh
# -------------------------------------
# Installs fonts that aren't available in Homebrew.
#
# Currently installs:
#   - ProggyVector Regular — scalable programming font from github.com/bluescan/proggyfonts
#
# To add more fonts later:
#   1. Find the direct download URL for the .ttf or .otf file
#   2. Add a new block following the same pattern below
#   3. Commit and push — chezmoi will run this script again because the file hash changed
#
# Fonts install to ~/Library/Fonts (user fonts, no sudo needed)
# macOS picks them up immediately — no restart required
#

set -e

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

echo ""
echo "→ [04] Installing fonts"

# ──────────────────────────────────────────────
# ProggyVector Regular
# ──────────────────────────────────────────────
PROGGY_URL="https://github.com/bluescan/proggyfonts/raw/master/ProggyVector/ProggyVector-Regular.ttf"
PROGGY_FILE="$FONT_DIR/ProggyVector-Regular.ttf"

if [[ -f "$PROGGY_FILE" ]]; then
    echo "  ✓ ProggyVector already installed — skipping"
else
    echo "  Installing ProggyVector Regular..."
    curl -fsSL "$PROGGY_URL" -o "$PROGGY_FILE"
    echo "  ✓ ProggyVector installed"
fi

echo ""
echo "  All fonts installed to ~/Library/Fonts"
echo "  Select in iTerm2: Preferences → Profiles → Text → Font"
echo ""
