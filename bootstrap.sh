#!/bin/bash
#
# bootstrap.sh — Fresh Mac Setup
# ================================
# Run this on a brand new Mac. It installs everything from nothing.
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
#    - This script installs the CLI, but it needs the desktop app
#      already running and signed in to connect to it
#
# 3. ENABLE DEVELOPER SETTINGS IN 1PASSWORD
#    - Open 1Password → Settings → Developer
#    - Turn ON: "Integrate with 1Password CLI"
#    - Turn ON: "Use the SSH Agent"
#    - When it asks about SSH key names on disk, choose "Use Key Names"
#    - These settings let the CLI and git talk to 1Password
#
# 4. KNOW YOUR MAC PASSWORD
#    - Homebrew will ask for your Mac user password during install
#    - This is your Mac login password, not your 1Password password
#
# That's it. Everything else is handled by this script.
#
# ============================================================
# HOW TO RUN
# ============================================================
#
# Option A — If you have this file on the machine (USB, AirDrop, etc.):
#   Open Terminal (Applications → Utilities → Terminal)
#   Navigate to wherever you saved it:
#     cd ~/Downloads
#   Make it executable and run it:
#     chmod +x bootstrap.sh
#     ./bootstrap.sh
#
# Option B — Run directly from GitHub (after first upload):
#   Open Terminal and paste this one line:
#     bash <(curl -fsSL https://raw.githubusercontent.com/JudgeJules/new_mac_setup/main/bootstrap.sh)
#
# ============================================================
# WHAT IT DOES (in order)
# ============================================================
#
#   1. Installs Xcode Command Line Tools (git, compilers, etc.)
#   2. Installs Homebrew (Mac package manager)
#   3. Installs 1Password CLI (so chezmoi can pull secrets)
#   4. Installs chezmoi (dotfile manager)
#   5. Clones your dotfiles repo and applies everything
#
# Safe to run more than once — each step checks if it's already
# done before running. If something fails halfway through, fix
# the issue and run it again.
#

set -e  # Stop on any error

# ============================================================
# CONFIGURATION — Change these to your values
# ============================================================
GITHUB_USERNAME="JudgeJules"            # Your GitHub username
DOTFILES_REPO="new_mac_setup"          # Your dotfiles repo name
# ============================================================

echo ""
echo "============================================"
echo "  Fresh Mac Bootstrap"
echo "  $(date)"
echo "============================================"
echo ""

# ----------------------------------------------------------
# Step 1: Xcode Command Line Tools
# ----------------------------------------------------------
echo "→ Step 1: Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    echo "  ✓ Already installed"
else
    echo "  Installing... (this may take several minutes)"
    echo "  A popup may appear — click 'Install' if it does."

    # Trigger the install
    xcode-select --install 2>/dev/null || true

    # Wait for it to finish
    echo "  Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 10
    done
    echo "  ✓ Installed"
fi
echo ""

# ----------------------------------------------------------
# Step 2: Homebrew
# ----------------------------------------------------------
echo "→ Step 2: Homebrew"

if command -v brew &>/dev/null; then
    echo "  ✓ Already installed"
else
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    # Apple Silicon Macs use /opt/homebrew, Intel uses /usr/local
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "  ✓ Installed (Apple Silicon)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        echo "  ✓ Installed (Intel)"
    else
        echo "  ✗ Homebrew install failed — brew not found"
        exit 1
    fi
fi
echo ""

# ----------------------------------------------------------
# Step 3: 1Password CLI
# ----------------------------------------------------------
echo "→ Step 3: 1Password CLI"

if command -v op &>/dev/null; then
    echo "  ✓ Already installed"
else
    echo "  Installing 1Password CLI..."
    brew install --cask 1password-cli
    echo "  ✓ Installed"
fi

# Verify 1Password CLI can talk to the desktop app
echo "  Checking 1Password connection..."
if op account list &>/dev/null; then
    echo "  ✓ Connected to 1Password"
else
    echo ""
    echo "  ⚠  1Password CLI is installed but can't connect."
    echo "  Before continuing, open 1Password and enable:"
    echo "    Settings → Developer → Integrate with 1Password CLI"
    echo "    Settings → Developer → Use the SSH Agent"
    echo ""
    read -p "  Press Enter when you've done that..."

    # Try again
    if op account list &>/dev/null; then
        echo "  ✓ Connected to 1Password"
    else
        echo "  ✗ Still can't connect. You may need to restart 1Password."
        echo "  Run this script again after fixing it."
        exit 1
    fi
fi
echo ""

# ----------------------------------------------------------
# Step 4: chezmoi
# ----------------------------------------------------------
echo "→ Step 4: chezmoi"

if command -v chezmoi &>/dev/null; then
    echo "  ✓ Already installed"
else
    echo "  Installing chezmoi..."
    brew install chezmoi
    echo "  ✓ Installed"
fi
echo ""

# ----------------------------------------------------------
# Step 5: Initialize dotfiles
# ----------------------------------------------------------
echo "→ Step 5: Dotfiles"

if [[ -d "${HOME}/.local/share/chezmoi" ]]; then
    echo "  chezmoi already initialized."
    echo "  Pulling latest and applying..."
    chezmoi update
    echo "  ✓ Updated and applied"
else
    echo "  Initializing from ${GITHUB_USERNAME}/${DOTFILES_REPO}..."
    chezmoi init --apply "${GITHUB_USERNAME}"
    echo "  ✓ Dotfiles cloned and applied"
fi
echo ""

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
echo "============================================"
echo "  Bootstrap complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal tab (so your shell config loads)"
echo "  2. Run 'chezmoi cd' to see your dotfiles source"
echo "  3. Run 'chezmoi diff' anytime to preview changes"
echo ""
echo "Your dotfiles are managed at:"
echo "  Source: ~/.local/share/chezmoi/"
echo "  Repo:   github.com/${GITHUB_USERNAME}/${DOTFILES_REPO}"
echo ""
