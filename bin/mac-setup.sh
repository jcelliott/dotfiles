#!/usr/bin/env bash
# Setup a new Mac computer
# Run from Github: bash <(curl -sSL https://raw.githubusercontent.com/jcelliott/dotfiles/master/bin/mac_setup.sh)

# Assumptions: TODO

set -euo pipefail

function cinfo() {
  echo -e "\x1b[32m$1\x1b[0m" # green
}

# Set machine name
cinfo ">>> Setting machine name"
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'
# Ask for the administrator password upfront
sudo -v

# Set computer name (as done via System Preferences → Sharing)
read -p "Enter Computer Name: " computer_name
sudo scutil --set ComputerName "$$computer_name"

# Set host name
read -p "Enter Host Name: " host_name; \
sudo scutil --set HostName "$$host_name.local"; \
sudo scutil --set LocalHostName "$$host_name"; \
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$$host_name"

# Install homebrew
cinfo ">>> Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install git

# Setup ssh key with Github
cinfo ">>> Setup new ssh key"
ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
cat "$HOME/.ssh/id_rsa.pub" | pbcopy
cinfo "New SSH public key copied to clipboard, please add to Github: https://github.com/settings/ssh/new"

read -p "Press enter to continue..."
ssh-add -K "$HOME/.ssh/id_rsa"

# Setup dotfiles repo
cinfo ">>> Setup dotfiles repo"
cd
git init
git remote add origin git@github.com:jcelliott/dotfiles.git
git fetch
git branch master origin/master
git reset --hard origin/master
git submodule init
git submodule update

# Install software
cinfo ">>> Installing software"
brew bundle --global --verbose

# Install other utilities
go get github.com/jcelliott/utils/duration-fmt
go get github.com/jcelliott/utils/sysinfo

# Set shell
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)

# Mac settings
cinfo ">>> Changing Mac settings"
bin/mac-settings.sh

cinfo "TODO: commands to run in fish:"
echo "fundle install"
echo "base16-default-dark"