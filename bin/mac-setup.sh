#!/usr/bin/env bash
# Setup a new Mac computer
# Run from Github: bash <(curl -sSL https://raw.githubusercontent.com/jcelliott/dotfiles/master/bin/mac-setup.sh)

set -euo pipefail

function cinfo() {
    echo -e "\x1b[32m$1\x1b[0m" # green
}
function cwarn() {
    echo -e "\x1b[33m$1\x1b[0m" # green
}

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'
# Ask for the administrator password upfront
cinfo ">>> Admin password:"
sudo -v

# Set machine name
cinfo ">>> Setting machine name"
# Set computer name (as done via System Preferences → Sharing)
read -p "Enter Computer Name: " computer_name
sudo scutil --set ComputerName "$computer_name"

# Set host name
read -p "Enter Host Name: " host_name
sudo scutil --set HostName "$host_name.local"
sudo scutil --set LocalHostName "$host_name"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$host_name"

# Install homebrew
cinfo ">>> Installing homebrew"
if command -v brew; then
    cwarn "Homebrew already installed, skipping"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew install git
fi

# Setup ssh key with Github
cinfo ">>> Setup new ssh key"
if [ -f $HOME/.ssh/id_rsa ]; then
    cwarn "SSH key file already exists, skipping"
else
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
    cat "$HOME/.ssh/id_rsa.pub" | pbcopy
    cinfo "New SSH public key copied to clipboard, please add to Github: https://github.com/settings/ssh/new"
    read -p "Press enter to continue..."
fi

ssh-add -K "$HOME/.ssh/id_rsa"

# Setup dotfiles repo
cinfo ">>> Setup dotfiles repo"
echo "This will potentially overwrite configuration files"
read -p "Continue? [yN]: " confirm && [[ $confirm == [yY] ]] || exit 1

cd

if [ -d $HOME/.git ]; then
    cwarn "Home directory git repo already exists, skipping"
else
    git init
    git remote add origin git@github.com:jcelliott/dotfiles.git
    git fetch
    git branch master origin/master
    git reset --hard origin/master
    git submodule init
    git submodule update
fi

# Install software
cinfo ">>> Installing software"
brew bundle --global --verbose

# Install other utilities
mkdir -p "$HOME/src"
export GOPATH=$HOME/src/go
go get github.com/jcelliott/utils/duration-fmt
go get github.com/jcelliott/utils/sysinfo

# Set shell
if grep "fish" /etc/shells; then
    cwarn "fish already added to shells, skipping"
else
    which fish | sudo tee -a /etc/shells
fi
chsh -s $(which fish)

# Mac settings
cinfo ">>> Changing Mac settings"
bin/mac-settings.sh

cinfo "TODO: commands to run in fish:"
echo "fundle install"
echo "base16-default-dark"
