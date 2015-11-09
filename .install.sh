#!/bin/bash

function warn_installed {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

# copy git configuration
[ -f ~/.gitconfig ]\
  && warn_installed ~/.gitconfig\
  || cp gitconfig .gitconfig

# install homebrew and packages
which brew &> /dev/null\
  && warn_installed brew\
  || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew upgrade --all
brew install bash-completion coreutils git gnu-sed nmap ssh-copy-id the_silver_searcher tmux vim wget watch

# install Vundle
[ -d ~/.vim/bundle/Vundle.vim/ ]\
  && warn_installed Vundle\
  || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# install molokai color scheme
mkdir -p ~/.vim/colors
[ -f ~/.vim/colors/molokai.vim ]\
  && warn_installed 'vim colorscheme: molokai'\
  || wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/colors/molokai.vim

# install powerline fonts
ls ~/Library/Fonts/ | grep -i 'for powerline' &> /dev/null
if [ $? -eq 0 ]; then
  warn_installed 'powerline fonts'
else
  git clone https://github.com/powerline/fonts.git /tmp/pl-fonts
  /tmp/pl-fonts/install.sh
  rm -rf /tmp/pl-fonts
fi

# install cluster ssh
gem list | grep i2cssh &> /dev/null\
  && warn_installed i2cssh\
  || sudo gem install i2cssh

# install liquidprompt
if [ -d ~/liquidprompt/ ]; then
  warn_installed liquidprompt
else
  git clone https://github.com/nojhan/liquidprompt.git ~/liquidprompt
  echo '[[ $- = *i* ]] && source ~/liquidprompt/liquidprompt' >> ~/.bashrc
  cp ~/liquidprompt/liquidpromptrc-dist ~/.liquidpromptrc
fi

# install slate window manager
[ -d /Applications/Slate.app ]\
  && warn_installed Slate\
  || $(curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications/)

# install chrome
if [ -d /Applications/Google\ Chrome.app/ ]; then
  warn_installed Google Chrome
else
  cd /tmp
  wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
  open -W /tmp/googlechrome.dmg
  sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
  umount /Volumes/Google\ Chrome/
  rm -f /tmp/googlechrome.dmg
fi
