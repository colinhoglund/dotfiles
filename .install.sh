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
brew install bash-completion ssh-copy-id wget nmap coreutils tmux vim gnu-sed

# install cluster ssh
gem list | grep i2cssh &> /dev/null\
 && echo "${warn_text}i2cssh already installed"\
 || sudo gem install i2cssh

# install slate window manager
[ -d /Applications/Slate.app ]\
  && echo "${warn_text}Slate already installed"\
  || $(curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications/)
