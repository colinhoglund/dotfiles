#!/bin/bash

warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0): "

# copy git configuration
[ -f ~/.gitconfig ]\
 && echo "${warn_text}~/.gitconfig already exists"\
 || cp gitconfig .gitconfig

# install homebrew and packages
which brew &> /dev/null\
 && echo "${warn_text}brew already installed"\
 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew install bash-completion coreutils git gnu-sed nmap ssh-copy-id tmux vim wget 

# install cluster ssh
gem list | grep i2cssh &> /dev/null\
 && echo "${warn_text}i2cssh already installed"\
 || sudo gem install i2cssh

# install slate window manager
[ -d /Applications/Slate.app ]\
  && echo "${warn_text}Slate already installed"\
  || $(curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications/)

# install chrome
if [ -d /Applications/Google\ Chrome.app/ ]; then
  echo "${warn_text}Google Chrome already installed"
else
  cd /tmp
  wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
  open -W /tmp/googlechrome.dmg
  sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
  umount /Volumes/Google\ Chrome/
  rm -f /tmp/googlechrome.dmg
fi
