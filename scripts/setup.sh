#!/bin/bash

links='
  .bash_profile
  .bash_prompt
  .ipython
  .hammerspoon
  .vimrc
  com.googlecode.iterm2.plist
'

git_config() {
  config='
    push.default=simple
    alias.df=diff
    alias.ci=commit
    alias.co=checkout
    alias.br=branch
    alias.pl=pull
    alias.ps=push
    alias.st=status
  '

  # setup git globals
  for id in user.name user.email; do
    if ! git config --global $id &> /dev/null; then
      echo -n "Enter a git config $id: "
      read -r input
      git config --global $id "$input"
    fi
  done

  for opt in $config; do
    key=$(echo "$opt" | cut -d= -f1)
    val=$(echo "$opt" | cut -d= -f2)
    git config --global "$key" "$val"
  done
  git config --global alias.up "!f() { git pull && git submodule update --init --recursive; }; f"
  git config --global pull.rebase false

  # alias https to ssh so Golang private repos that bypass GOPROXY work properly
  git config --global url."git@github.com:".insteadOf "https://github.com/"
}

vim_config() {
  # create vi alias
  [ -f /usr/local/bin/vim ] && ln -fs /usr/local/bin/vim /usr/local/bin/vi

  # install molokai color scheme
  mkdir -p ~/.vim/colors
  if [ -f ~/.vim/colors/molokai.vim ]; then
    warn_installed 'vim colorscheme: molokai'
  else
    wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/colors/molokai.vim
  fi

  # install Vundle
  if [ -d ~/.vim/bundle/Vundle.vim/ ]; then
    warn_installed Vundle
  else
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  /usr/local/bin/vim +PluginInstall +qall
}

link() {
  for i in $links; do
    file=~/$i
    # backup existing file if it's not a soft link
    if [ -e "$file" ] && [ ! -L "$file" ]; then
      rm -rf "$file.bak"
      mv "$file" "$file.bak"
    fi
    ln -fhs "$(pwd)/$i" "$file"
  done
}

unlink() {
  for i in $links; do
    file=~/$i
    # only remove if it's a link
    [ -h "$file" ] && rm "$file"
  done
}

iterm() {
  if [ -d /Applications/iTerm.app/ ]; then
    warn_installed iTerm
  else
    iterm_url=$(curl -s https://iterm2.com/downloads.html\
                | grep -o 'https://iterm2.com/downloads/stable/.*zip'\
                | head -1)
    iterm_zipfile=$(basename "$iterm_url")

    cd /tmp || exit 1
    wget "$iterm_url"
    unzip -qd /Applications/ "$iterm_zipfile"
    rm -f "$iterm_zipfile"
  fi
}

chrome() {
  if [ -d /Applications/Google\ Chrome.app/ ]; then
    warn_installed 'Google Chrome'
  else
    cd /tmp || exit 1
    wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
    hdiutil attach -nobrowse /tmp/googlechrome.dmg
    sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
    umount /Volumes/Google\ Chrome/
    rm -f /tmp/googlechrome.dmg
  fi
}

slack() {
  if [ -d /Applications/Slack.app/ ]; then
    warn_installed 'Slack'
  else
    cd /tmp || exit 1
    wget https://slack.com/ssb/download-osx -O slack.dmg
    hdiutil attach -nobrowse /tmp/slack.dmg
    sudo cp -r /Volumes/Slack.app/Slack.app /Applications/
    umount /Volumes/Slack.app/
    rm -f /tmp/slack.dmg
  fi
}

warn_installed() {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

usage() {
    echo "Usage: $0 <link|unlink|git|vim|iterm|chrome|slack>"
}

main() {
  [ -z "$1" ] && usage && exit 1

  case "$1" in
    chrome) chrome;;
    slack) slack;;
    git) git_config;;
    iterm) iterm;;
    link) link;;
    unlink) unlink;;
    vim) vim_config;;
    *) usage;;
  esac
}

main "$1"
