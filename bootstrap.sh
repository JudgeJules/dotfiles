#!/bin/bash
#
# bootstrap.sh — Fresh Mac Setup
# ================================
# The ONLY thing you run manually on a brand new Mac.
# This script does the bare minimum, then hands off to chezmoi,
# which handles everything else via run_once scripts inside the repo.
#
# ============================================================
# BEFORE YOU RUN THIS — Do these things manually first:
# ============================================================
#
# 1. SIGN INTO YOUR MAC
#    - Complete the macOS setup wizard (Apple ID, user account, etc.)
#    - Make sure you're connected to the internet
#
# 2. INSTALL 1PASSWORD (the desktop app)
#    - Download from https://1password.com/downloads/mac/
#    - Install it, open it, and sign in to your account(s)
#
# 3. ENABLE DEVELOPER SETTINGS IN 1PASSWORD
#    - Open 1Password → Settings → Developer
#    - Turn ON: "Integrate with 1Password CLI"
#    - Turn ON: "Use the SSH Agent"
#    - When it asks about SSH key names on disk, choose "Use Key Names"
#
# 4. KNOW YOUR MAC PASSWORD
#    - Homebrew will ask for your Mac login password during install
#
# That's it. Everything else is handled automatically.
#
# ============================================================
# HOW TO RUN
# ============================================================
#
# Option A — Run directly from GitHub (recommended):
#   Open Terminal (Applications → Utilities → Terminal) and paste:
#
#     bash <(curl -fsSL https://raw.githubusercontent.com/JudgeJules/dotfiles/main/bootstrap.sh)
#
# Option B — If you have this file locally (USB, AirDrop, etc.):
#   Open Terminal and run:
#     cd ~/Downloads
#     chmod +x bootstrap.sh
#     ./bootstrap.sh
#
# ============================================================
# HOW THIS WORKS
# ============================================================
#
# This script only does two things:
#   1. Installs Xcode Command Line Tools (needed for git)
#   2. Runs chezmoi's one-line installer, which:
#      a. Downloads the chezmoi binary (no Homebrew needed)
#      b. Clones your dotfiles repo from GitHub
#      c. Runs chezmoi apply, which triggers run_once scripts
#
# The run_once scripts inside the repo handle EVERYTHING else:
#   - Installing Homebrew
#   - Installing 1Password CLI
#   - Installing all your apps (Brewfile)
#   - Configuring your shell, git, SSH, etc.
#
# This means the bootstrap script stays tiny and stable,
# while all the real setup logic lives in the repo where
# it's version-controlled and easy to update.
#
# Safe to run more than once — every step is idempotent.
#

set -e  # Stop on any error

GITHUB_USERNAME="JudgeJules"
DOTFILES_REPO="dotfiles"

echo ""
echo "============================================"
echo "  Fresh Mac Bootstrap"
echo "  $(date)"
echo "============================================"
echo ""

# ----------------------------------------------------------
# Step 1: Xcode Command Line Tools
# ----------------------------------------------------------
# These provide git, which chezmoi needs to clone the repo.
# This is the one thing that MUST exist before chezmoi can work.
# ----------------------------------------------------------
echo "→ Step 1: Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    echo "  ✓ Already installed"
else
    echo "  Installing..."
    echo ""
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │  ACTION REQUIRED:                                   │"
    echo "  │  A macOS popup will appear asking you to install.   │"
    echo "  │  It may be BEHIND this Terminal window.             │"
    echo "  │  Use Cmd+Tab or check your Dock to find it.        │"
    echo "  │  Click 'Install' and wait for it to finish.         │"
    echo "  │  This can take 5-15 minutes depending on your       │"
    echo "  │  internet connection. This script will wait.        │"
    echo "  └─────────────────────────────────────────────────────┘"
    echo ""

    xcode-select --install 2>/dev/null || true

    # Wait for installation to complete
    echo "  Waiting for Xcode CLI tools to finish installing..."
    echo "  (This script is not frozen — it's checking every 10 seconds)"
    printf "  "
    until xcode-select -p &>/dev/null; do
        printf "."
        sleep 10
    done
    echo ""
    echo "  ✓ Installed"
fi
echo ""

# ----------------------------------------------------------
# Step 2: Install chezmoi + clone repo + apply dotfiles
# ----------------------------------------------------------
# chezmoi's installer needs nothing — it downloads a single
# binary via curl. No Homebrew, no package manager.
#
# The --apply flag tells it to immediately run chezmoi apply
# after cloning, which triggers any run_once scripts in the
# repo. Those scripts handle Homebrew, 1Password CLI, apps,
# and everything else.
# ----------------------------------------------------------
echo "→ Step 2: Installing chezmoi and applying dotfiles"
echo "  This will clone ${GITHUB_USERNAME}/${DOTFILES_REPO}"
echo "  and run all setup scripts inside the repo."
echo ""

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin init --apply "${GITHUB_USERNAME}" --source "${HOME}/.local/share/chezmoi"

echo ""
echo "============================================"
echo "  Bootstrap complete!"
echo "============================================"
echo ""
echo "What just happened:"
echo "  1. Xcode CLI tools were installed"
echo "  2. chezmoi was installed and your dotfiles applied"
echo "  3. run_once scripts inside the repo did the rest"
echo ""
echo "Next steps:"
echo "  • Open a NEW terminal tab (so your shell config loads)"
echo "  • Run 'chezmoi cd' to see your dotfiles source"
echo "  • Run 'chezmoi diff' anytime to preview changes"
echo ""
echo "To update later:"
echo "  chezmoi update    — pulls latest from GitHub and applies"
echo ""
