#!/usr/bin/env bash
# Set basic mac settings

set -euo pipefail

function cinfo() {
  echo -e "\x1b[32m$1\x1b[0m" # green
}

function set_keyboard_settings() {
  cinfo "Update keyboard settings"
  # Disable automatic capitalization
  defaults write -g NSAutomaticCapitalizationEnabled -bool false
  # Disable smart dashes
  defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
  # Disable automatic period substitution
  defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
  # Disable smart quotes
  defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable “natural” (Lion-style) scrolling
  defaults write com.apple.swipescrolldirection -bool true

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write -g AppleKeyboardUIMode -int 3

  # Disable press-and-hold for keys in favor of key repeat
  defaults write -g ApplePressAndHoldEnabled -bool false

	# Set a fast keyboard repeat rate
	defaults write -g KeyRepeat -int 2
	defaults write -g InitialKeyRepeat -int 20

	# Stop iTunes from responding to the keyboard media keys
	launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
}

function set_finder_settings() {
  cinfo "Update finder settings"
	# Show icons for hard drives, servers, and removable media on the desktop
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

	# Finder: show status bar
	defaults write com.apple.finder ShowStatusBar -bool true

	# Finder: show path bar
	defaults write com.apple.finder ShowPathbar -bool true

	# Display full POSIX path as Finder window title
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

	# Keep folders on top when sorting by name
	defaults write com.apple.finder _FXSortFoldersFirst -bool true

	# Avoid creating .DS_Store files on network or USB volumes
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Show the ~/Library folder
	chflags nohidden ~/Library
	# Show the /Volumes folder
	sudo chflags nohidden /Volumes
}

function set_dock_dashboard_settings() {
  cinfo "Update dock and dashboard settings"
	# Change minimize/maximize window effect
	defaults write com.apple.dock mineffect -string "scale"

	# Move the dock to the right
	defaults write com.apple.dock 'orientation' -string 'right'

	# Wipe all (default) app icons from the Dock
	defaults write com.apple.dock persistent-apps -array

	# Disable Dashboard
	defaults write com.apple.dashboard mcx-disabled -bool true

	# Don’t automatically rearrange Spaces based on most recent use
	defaults write com.apple.dock mru-spaces -bool false
}

function set_general_settings() {
  cinfo "Update general settings"
	# Use plain text mode for new TextEdit documents
	defaults write com.apple.TextEdit RichText -int 0
	# Open and save files as UTF-8 in TextEdit
	defaults write com.apple.TextEdit PlainTextEncoding -int 4
	defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

	# Prevent Time Machine from prompting to use new hard drives as backup volume
	defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

	# Prevent Photos from opening automatically when devices are plugged in
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'
# Ask for the administrator password upfront
sudo -v

set_keyboard_settings
set_finder_settings
set_dock_dashboard_settings
set_general_settings

cinfo "Settings updated. Please reboot."