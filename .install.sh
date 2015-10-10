#!/bin/bash

# copy git configuration
if [ ! -f .gitconfig ]; then
  cp gitconfig .gitconfig
else
  echo '~/.gitconfig already exists'
fi

# install homebrew and packages
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install bash-completion ssh-copy-id wget nmap coreutils tmux vim gnu-sed

# install cluster ssh
gem list | grep i2cssh &> /dev/null && echo 'i2cssh already installed' || sudo gem install i2cssh

# install slate window manager
if [ ! -d /Applications/Slate.app ]; then
  cd /Applications && curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz
else
  echo 'Slate already installed'
fi
