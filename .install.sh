#!/bin/bash

# Install Homebrew and packages
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install bash-completion ssh-copy-id wget nmap coreutils vim gnu-sed
sudo gem install i2cssh
