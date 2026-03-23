#!/bin/bash
#
# run_once_before_05-macos-defaults.sh
# --------------------------------------
# Sets macOS system preferences via `defaults write`.
# Much faster than clicking through System Settings manually.
#
# chezmoi runs this exactly once (tracked by hash).
# To re-run after changes: `chezmoi apply --force`
#
# After this runs, some changes need apps to restart to take effect.
# The script handles this at the end with `killall`.
#
# To see what a setting currently is:
#   defaults read <domain> <key>
# To find what changed after tweaking in System Settings:
#   defaults read > before.txt, change setting, defaults read > after.txt, diff before.txt after.txt
#

set -e

echo ""
echo "→ [05] macOS defaults"

# ──────────────────────────────────────────────
# Dock
# ──────────────────────────────────────────────

# Position on screen
defaults write com.apple.dock orientation -string "bottom"

# Auto-hide
defaults write com.apple.dock autohide -bool true

# Auto-hide speed — delay before appearing, animation duration
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock autohide-time-modifier -float 0.1

# Icon size (pixels)
defaults write com.apple.dock tilesize -int 48

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their application icon (cleaner Dock)
defaults write com.apple.dock minimize-to-application -bool true

echo "  ✓ Dock"

# ──────────────────────────────────────────────
# Finder
# ──────────────────────────────────────────────

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files (dotfiles, etc.)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar at bottom of Finder window
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar at bottom of Finder window (item count, disk space)
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view in Finder (options: Nlsv=list, icnv=icon, clmv=column, glyv=gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search current folder by default (not whole Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable the warning when emptying the trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

echo "  ✓ Finder"

# ──────────────────────────────────────────────
# Keyboard
# ──────────────────────────────────────────────

# Key repeat — how fast keys repeat when held down
# Lower = faster. 2 is very fast, 6 is Mac default
defaults write NSGlobalDomain KeyRepeat -int 2

# Delay before key repeat kicks in
# Lower = shorter delay. 15 is very short, 68 is Mac default
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart quotes (they break code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes (they break code)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable period substitution (double-space → period)
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "  ✓ Keyboard"

# ──────────────────────────────────────────────
# Trackpad
# ──────────────────────────────────────────────

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Traditional scroll direction (swipe down to scroll up)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "  ✓ Trackpad"

# ──────────────────────────────────────────────
# Restart affected apps
# ──────────────────────────────────────────────
# Changes don't take effect until the app restarts.
# `|| true` prevents the script from failing if an app isn't running.

echo ""
echo "  Restarting affected apps..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo "  ✓ macOS defaults applied"
echo "  Note: some changes (keyboard, trackpad) require logout/login to fully take effect"
echo ""