#!/bin/bash

# copy git configuration
if [ ! -f .gitconfig ]; then
  cp gitconfig .gitconfig
fi

# install homebrew and packages
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install bash-completion ssh-copy-id wget nmap coreutils tmux vim gnu-sed

# install cluster ssh
sudo gem install i2cssh

# install slate window manager
cd /Applications && curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz
