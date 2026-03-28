#!/usr/bin/env bash
#
# run_once_before_05-macos-defaults.sh
# --------------------------------------
# Sets macOS system preferences via `defaults write`.
# Based on jordan-rs/dotfiles-v2/.macos (Tahoe edition), adapted for chezmoi.
#
# STATUS TAGS:
#   [VERIFIED-26]   Confirmed working on macOS 26 Tahoe
#   [LIKELY-OK]     Same key since Ventura/Sonoma; plausibly still works
#   [UNCERTAIN]     Key exists but Tahoe behavior not confirmed
#   [DEPRECATED]    Apple has flagged the underlying tool as deprecated
#
# chezmoi runs this exactly once (tracked by hash).
# To re-run after changes: `chezmoi apply --force`
#
# To find what a setting currently is:
#   defaults read <domain> <key>
# To find what changed after tweaking in System Settings:
#   defaults read > before.txt, change setting, defaults read > after.txt, diff before.txt after.txt
#

echo ""
echo "→ [05] macOS defaults"

# Close any open System Settings panes to prevent them from overriding settings
osascript -e 'tell application "System Settings" to quit' 2>/dev/null
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` timestamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###############################################################################
# General UI/UX                                                               #
###############################################################################

# Reduce transparency — tones down Liquid Glass effects. [VERIFIED-26]
# Set to `true` to disable Liquid Glass effects entirely.
defaults write com.apple.universalaccess reduceTransparency -bool false

# Dark mode [LIKELY-OK]
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Set sidebar icon size to medium. [LIKELY-OK]
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars. [VERIFIED-26]
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Increase window resize speed for Cocoa applications. [LIKELY-OK]
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default. [VERIFIED-26]
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default. [VERIFIED-26]
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default. [VERIFIED-26]
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once print jobs complete. [LIKELY-OK]
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the "Are you sure you want to open this application?" dialog. [UNCERTAIN on Tahoe]
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Remove duplicates in the "Open With" menu. [LIKELY-OK]
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user

# Disable Resume system-wide (windows reopen on relaunch). [LIKELY-OK]
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

# Disable automatic termination of inactive apps. [LIKELY-OK]
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Reveal IP address, hostname, OS version when clicking the clock in login window. [LIKELY-OK]
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable automatic capitalization. [VERIFIED-26]
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes. [VERIFIED-26]
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution. [VERIFIED-26]
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes. [VERIFIED-26]
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct. [VERIFIED-26]
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "  ✓ General UI/UX"


###############################################################################
# Trackpad, Mouse, Keyboard, Bluetooth, and Input                            #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen. [VERIFIED-26]
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom-right corner to right-click. [LIKELY-OK]
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable "natural" (Lion-style) scrolling. [VERIFIED-26]
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Bluetooth audio quality. [UNCERTAIN]
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" -int 80
defaults write com.apple.BluetoothAudioAgent "Apple Initial Bitpool (editable)" -int 40
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool" -int 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Max" -int 80
defaults write com.apple.BluetoothAudioAgent "Negotiated Bitpool Min" -int 40

# Enable full keyboard access for all controls (Tab in modal dialogs). [LIKELY-OK]
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with Ctrl to zoom. [LIKELY-OK]
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Follow keyboard focus while zoomed in. [LIKELY-OK]
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat. [VERIFIED-26]
# Essential for VS Code vim mode and any app that needs held keys.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set keyboard repeat rate. Lower is faster. [VERIFIED-26]
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "  ✓ Trackpad, Keyboard & Input"


###############################################################################
# Energy Saving                                                               #
###############################################################################

# Enable lid wakeup. [LIKELY-OK]
sudo pmset -a lidwake 1

# Restart automatically on power loss. [LIKELY-OK]
sudo pmset -a autorestart 1

# Sleep the display after 15 minutes. [VERIFIED-26]
sudo pmset -a displaysleep 15

# Disable machine sleep while charging. [LIKELY-OK]
sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery. [LIKELY-OK]
sudo pmset -b sleep 5

# Set standby delay to 24 hours (default is 1 hour). [LIKELY-OK]
sudo pmset -a standbydelay 86400

echo "  ✓ Energy Saving"


###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins. [VERIFIED-26]
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Screensaver kicks in after 30 minutes
defaults -currentHost write com.apple.screensaver idleTime -int 1800

# Save screenshots to ~/Screenshots. [VERIFIED-26]
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format. [VERIFIED-26]
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots. [VERIFIED-26]
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs. [UNCERTAIN on Tahoe]
defaults write NSGlobalDomain AppleFontSmoothing -int 1

echo "  ✓ Screen"


###############################################################################
# Finder                                                                      #
###############################################################################

# Allow quitting Finder via ⌘+Q. [VERIFIED-26]
defaults write com.apple.finder QuitMenuItem -bool true

# Disable window animations and Get Info animations. [LIKELY-OK]
defaults write com.apple.finder DisableAllAnimations -bool true

# Set default location for new Finder windows to home folder. [VERIFIED-26]
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Show icons for hard drives, servers, and removable media on the desktop. [VERIFIED-26]
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show hidden files (dotfiles, etc.). [VERIFIED-26]
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions. [VERIFIED-26]
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar. [VERIFIED-26]
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar. [VERIFIED-26]
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title. [LIKELY-OK]
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name. [VERIFIED-26]
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Also keep folders on top on Desktop. [LIKELY-OK]
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

# When performing a search, search the current folder by default. [VERIFIED-26]
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension. [VERIFIED-26]
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories. [LIKELY-OK]
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes. [VERIFIED-26]
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification. [LIKELY-OK]
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted. [LIKELY-OK]
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use column view in all Finder windows by default. [VERIFIED-26]
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Disable the warning before emptying the Trash. [VERIFIED-26]
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder. [VERIFIED-26]
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Show the /Volumes folder. [VERIFIED-26]
sudo chflags nohidden /Volumes

# Expand the following File Info panes. [LIKELY-OK]
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

echo "  ✓ Finder"


###############################################################################
# Dock                                                                        #
###############################################################################

# Position on screen
defaults write com.apple.dock orientation -string "bottom"

# Set the icon size of Dock items to 48 pixels. [VERIFIED-26]
defaults write com.apple.dock tilesize -int 48

# Change minimize/maximize window effect. [VERIFIED-26]
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application's icon. [VERIFIED-26]
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items. [LIKELY-OK]
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock. [VERIFIED-26]
defaults write com.apple.dock show-process-indicators -bool true

# Enable highlight hover effect for stack grid view. [LIKELY-OK]
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Don't animate opening applications from the Dock. [VERIFIED-26]
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations. [LIKELY-OK]
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't group windows by application in Mission Control. [LIKELY-OK]
defaults write com.apple.dock expose-group-by-app -bool false

# Don't automatically rearrange Spaces based on most recent use. [VERIFIED-26]
defaults write com.apple.dock mru-spaces -bool false

# Auto-hide the Dock. [VERIFIED-26]
defaults write com.apple.dock autohide -bool true

# Auto-hide delay and animation. [VERIFIED-26]
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock autohide-time-modifier -float 0.1

# Make Dock icons of hidden applications translucent. [VERIFIED-26]
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock. [VERIFIED-26]
defaults write com.apple.dock show-recents -bool false

# Remove all default Apple apps from Dock (start clean). [VERIFIED-26]
defaults write com.apple.dock persistent-apps -array

# Hot corners. [VERIFIED-26]
# Possible values:
#  0 = no-op  2 = Mission Control  3 = Show app windows  4 = Desktop
#  5 = Screen saver  10 = Put display to sleep  12 = Notification Center
#  13 = Lock Screen  14 = Quick Note
# Top right → Mission Control
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom right → Desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

echo "  ✓ Dock"


###############################################################################
# Spotlight                                                                   #
###############################################################################

# Disable Spotlight entirely — Raycast handles everything
sudo mdutil -a -i off 2>/dev/null || true
killall mds > /dev/null 2>&1 || true

# Disable Spotlight web search suggestions
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true

# Remap Spotlight shortcut away from Cmd+Space so Raycast can use it
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" \
    ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true

echo "  ✓ Spotlight"


###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Don't send search queries to Apple. [LIKELY-OK]
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar. [LIKELY-OK]
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari's home page to about:blank for faster loading. [LIKELY-OK]
defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening 'safe' files automatically after downloading. [LIKELY-OK]
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Hide Safari's bookmarks bar by default. [LIKELY-OK]
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Enable Safari's debug menu. [LIKELY-OK]
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari's search banners default to Contains instead of Starts With. [LIKELY-OK]
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari. [LIKELY-OK]
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views. [LIKELY-OK]
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking. [LIKELY-OK]
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

# Disable auto-correct. [LIKELY-OK]
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Disable AutoFill. [LIKELY-OK]
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites. [LIKELY-OK]
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Block pop-up windows. [LIKELY-OK]
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Update extensions automatically. [LIKELY-OK]
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# Enable Tab key to highlight each item on a web page. [LIKELY-OK]
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

echo "  ✓ Safari"


###############################################################################
# Mail                                                                        #
###############################################################################

# Disable send and reply animations. [LIKELY-OK]
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

# Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com>. [LIKELY-OK]
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Add keyboard shortcut ⌘+Enter to send email. [LIKELY-OK]
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

# Display emails in threaded mode, sorted by date (oldest at top). [LIKELY-OK]
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "no"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

# Disable inline attachments (just show icons). [LIKELY-OK]
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

# Disable automatic spell checking. [LIKELY-OK]
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

echo "  ✓ Mail"


###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app. [LIKELY-OK]
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app. [VERIFIED-26]
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks (shell integration dividers). [LIKELY-OK]
defaults write com.apple.Terminal ShowLineMarks -int 0

echo "  ✓ Terminal"


###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup. [LIKELY-OK]
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "  ✓ Time Machine"


###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor. [LIKELY-OK]
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon. [LIKELY-OK]
# 0=App Icon, 1=Network Usage, 2=Disk Activity, 3=Memory Usage, 5=CPU Usage
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor. [LIKELY-OK]
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage. [LIKELY-OK]
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo "  ✓ Activity Monitor"


###############################################################################
# TextEdit, Disk Utility, QuickTime                                           #
###############################################################################

# Use plain text mode for new TextEdit documents. [LIKELY-OK]
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit. [LIKELY-OK]
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the debug menu in Disk Utility. [LIKELY-OK]
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true
defaults write com.apple.DiskUtility DUShowEveryPartition -bool true

# Auto-play videos when opened with QuickTime Player. [LIKELY-OK]
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

echo "  ✓ TextEdit, Disk Utility, QuickTime"


###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the WebKit Developer Tools in the Mac App Store. [UNCERTAIN]
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store. [UNCERTAIN]
defaults write com.apple.appstore ShowDebugMenu -bool true

# Enable the automatic update check. [LIKELY-OK]
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates every 14 days.
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 14

# Download newly available updates in background. [LIKELY-OK]
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates. [LIKELY-OK]
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Do NOT auto-install app updates (you decide when to update apps).
defaults write com.apple.commerce AutoUpdate -bool false

echo "  ✓ Mac App Store"


###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in. [LIKELY-OK]
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

echo "  ✓ Photos"


###############################################################################
# Messages                                                                    #
###############################################################################

# Disable automatic emoji substitution. [LIKELY-OK]
defaults write com.apple.messageshelper.MessageController SOInputLineSettings \
  -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes in Messages. [LIKELY-OK]
defaults write com.apple.messageshelper.MessageController SOInputLineSettings \
  -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# Disable continuous spell checking in Messages. [LIKELY-OK]
defaults write com.apple.messageshelper.MessageController SOInputLineSettings \
  -dict-add "continuousSpellCheckingEnabled" -bool false

echo "  ✓ Messages"


###############################################################################
# Google Chrome                                                               #
###############################################################################

# Disable the too-sensitive backswipe on trackpads. [LIKELY-OK]
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Disable the too-sensitive backswipe on Magic Mouse. [LIKELY-OK]
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# Use the system-native print preview dialog. [LIKELY-OK]
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default. [LIKELY-OK]
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

echo "  ✓ Google Chrome"


###############################################################################
# Transmission                                                                #
###############################################################################

# Use ~/Downloads to store incomplete downloads. [LIKELY-OK]
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

# Use ~/Downloads to store completed downloads. [LIKELY-OK]
defaults write org.m0k.transmission DownloadLocationConstant -bool true

# Don't prompt for confirmation before downloading. [LIKELY-OK]
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission MagnetOpenAsk -bool false

# Trash original torrent files. [LIKELY-OK]
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message. [LIKELY-OK]
defaults write org.m0k.transmission WarningDonate -bool false

# Hide the legal disclaimer. [LIKELY-OK]
defaults write org.m0k.transmission WarningLegal -bool false

# Randomize port on launch. [LIKELY-OK]
defaults write org.m0k.transmission RandomPort -bool true

echo "  ✓ Transmission"


###############################################################################
# Restart affected applications                                               #
###############################################################################

echo ""
echo "  Restarting affected apps..."

for app in \
  "Activity Monitor" \
  "Calendar" \
  "cfprefsd" \
  "Contacts" \
  "Dock" \
  "Finder" \
  "Google Chrome Canary" \
  "Google Chrome" \
  "Mail" \
  "Messages" \
  "Photos" \
  "Safari" \
  "SystemUIServer" \
  "Terminal" \
  "Transmission"; do
  killall "${app}" &> /dev/null || true
done

echo ""
echo "  ✓ macOS defaults applied"
echo ""
echo "Notes:"
echo "  • Some changes require a full logout or restart to take effect."
echo "  • If Safari keys didn't apply, grant Full Disk Access to Terminal in"
echo "    System Settings → Privacy & Security, then re-run."
echo "  • Liquid Glass settings cannot be fully controlled via defaults write"
echo "    as of macOS 26.3 — use System Settings → Appearance."
echo ""
