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
# Sound
# ──────────────────────────────────────────────

# Mute startup chime
sudo nvram SystemAudioVolume=" "

# Disable volume change feedback sound
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false

# Disable UI sound effects
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -bool false

echo "  ✓ Sound"

# ──────────────────────────────────────────────
# Screenshots
# ──────────────────────────────────────────────

# Create Screenshots folder if it doesn't exist
mkdir -p ~/Screenshots

# Save screenshots to ~/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots as PNG (options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

echo "  ✓ Screenshots"

# ──────────────────────────────────────────────
# Display & Sleep
# ──────────────────────────────────────────────

# Screensaver kicks in after 30 minutes (1800 seconds)
defaults -currentHost write com.apple.screensaver idleTime -int 1800

echo "  ✓ Display & Sleep"

# ──────────────────────────────────────────────
# Mac App Store
# ──────────────────────────────────────────────

# Check for updates every 14 days
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 14

# Download newly available updates in the background
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true

# Install system data files and security updates automatically
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

# Do NOT auto-install app updates (you decide when to update apps)
defaults write com.apple.commerce AutoUpdate -bool false

echo "  ✓ Mac App Store"

# ──────────────────────────────────────────────
# Keyboard (additional)
# ──────────────────────────────────────────────

# Disable press-and-hold for keys — enables key repeat in ALL apps
# This is essential for VS Code vim mode and any app that needs held keys
defaults write -g ApplePressAndHoldEnabled -bool false

# Enable full keyboard access for all controls
# Tab moves focus through ALL UI elements, not just text fields
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "  ✓ Keyboard (additional)"

# ──────────────────────────────────────────────
# Menu Bar
# ──────────────────────────────────────────────

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true

echo "  ✓ Menu Bar"

# ──────────────────────────────────────────────
# Dialogs
# ──────────────────────────────────────────────

# Expand save panel by default (shows full file browser immediately)
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "  ✓ Dialogs"

# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Reopen windows when relaunching an app
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

echo "  ✓ General"

# ──────────────────────────────────────────────
# Mission Control & Hot Corners
# ──────────────────────────────────────────────

# Hot corner values:
#  0  = no action
#  2  = Mission Control
#  3  = Application Windows
#  4  = Desktop
#  5  = Screen Saver
#  10 = Put Display to Sleep
#  11 = Launchpad
#  12 = Notification Center

# Top-right → Mission Control
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom-right → Desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

echo "  ✓ Hot Corners"

# ──────────────────────────────────────────────
# Finder (additional)
# ──────────────────────────────────────────────

# Show full POSIX path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "  ✓ Finder (additional)"

# ──────────────────────────────────────────────
# Dock (additional)
# ──────────────────────────────────────────────

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Remove all default Apple apps from Dock (start clean)
defaults write com.apple.dock persistent-apps -array

echo "  ✓ Dock (additional)"

# ──────────────────────────────────────────────
# Time Machine
# ──────────────────────────────────────────────

# Disable local Time Machine backups (saves significant disk space)
sudo tmutil disablelocal 2>/dev/null || true

echo "  ✓ Time Machine"

# ──────────────────────────────────────────────
# Security
# ──────────────────────────────────────────────

# Disable "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "  ✓ Security"

# ──────────────────────────────────────────────
# Bluetooth Audio
# ──────────────────────────────────────────────

# Enable high-quality Bluetooth audio codec (AAC)
# Dramatically improves sound quality with AirPods and other Bluetooth headphones
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" -int 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" -int 40
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" -int 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" -int 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" -int 40

echo "  ✓ Bluetooth Audio"

# ──────────────────────────────────────────────
# iCloud
# ──────────────────────────────────────────────

# Save new documents to local disk by default, not iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "  ✓ iCloud"

# ──────────────────────────────────────────────
# Disk Utility
# ──────────────────────────────────────────────

# Show all partitions and hidden volumes
defaults write com.apple.DiskUtility DUShowEveryPartition -bool true

echo "  ✓ Disk Utility"

# ──────────────────────────────────────────────
# Spotlight
# ──────────────────────────────────────────────

# Disable Spotlight web search results and suggestions
# (stops queries being sent to Apple)
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true

# Disable Spotlight entirely — Raycast handles everything
sudo mdutil -a -i off 2>/dev/null || true

# Change Spotlight shortcut away from Cmd+Space so Raycast can use it
# This remaps Spotlight to Cmd+Option+Space instead
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true

echo "  ✓ Spotlight"

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
killall Spotlight 2>/dev/null || true

echo ""
echo "  ✓ macOS defaults applied"
echo "  Note: some changes (keyboard, trackpad) require logout/login to fully take effect"
echo ""
