#!/bin/bash

links='
  .bash_profile
  .bash_prompt
  .ipython
  .slate
  .vimrc
'

gitconfig() {
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
    git config --global $id &> /dev/null
    [ "$?" -ne 0 ]\
      && echo -n "Enter a git config $id: "\
      && read input\
      && git config --global $id "$input"
  done

  for opt in $config; do
    key=`echo $opt | cut -d= -f1`
    val=`echo $opt | cut -d= -f2`
    git config --global $key $val
  done
  git config --global alias.up "!f() { git pull && git submodule update --init --recursive; }; f"
}

vimconfig() {
  brew install vim

  # create vi alias
  [ -f /usr/local/bin/vim ] && ln -fs /usr/local/bin/vim /usr/local/bin/vi

  # install molokai color scheme
  mkdir -p ~/.vim/colors
  [ -f ~/.vim/colors/molokai.vim ] \
    && warn_installed 'vim colorscheme: molokai' \
    || wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/colors/molokai.vim

  # install Vundle
  [ -d ~/.vim/bundle/Vundle.vim/ ] \
    && warn_installed Vundle \
    || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

  /usr/local/bin/vim +PluginInstall +qall
}

link() {
  for i in $links; do
    file=~/$i
    # backup existing file if it's not a soft link
    [ -e "$file" ] && [ ! -L "$file" ] \
      && rm -rf $file.bak \
      && mv $file $file.bak
    ln -fs $(pwd)/$i $file
  done
}

unlink() {
  for i in $links; do
    file=~/$i
    # only remove if it's a link
    [ -h "$file" ] && rm $file
  done
}

iterm() {
  if [ -d /Applications/iTerm.app/ ]; then
    warn_installed iTerm
  else
    iterm_url=$(curl -s https://www.iterm2.com/downloads.html\
                | grep -o 'https://iterm2.com/downloads/stable/.*zip'\
                | head -1)
    iterm_zipfile=$(basename $iterm_url)

    cd /tmp
    wget $iterm_url
    unzip -qd /Applications/ $iterm_zipfile
    rm -f $iterm_zipfile
  fi
}

chrome() {
  if [ -d /Applications/Google\ Chrome.app/ ]; then
    warn_installed 'Google Chrome'
  else
    cd /tmp
    wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
    hdiutil attach -nobrowse /tmp/googlechrome.dmg
    sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
    umount /Volumes/Google\ Chrome/
    rm -f /tmp/googlechrome.dmg
  fi
}

slate() {
  if [ -d /Applications/Slate.app ]; then
    warn_installed Slate
  else
    $(curl -s http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications/)
    # enable assistive devices
    os_x_version=$(sw_vers | grep ProductVersion | awk '{print $2}' | cut -d. -f1,2)
    slate_plist=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' /Applications/Slate.app/Contents/Info.plist)
    case "$os_x_version" in
      10.11)
        slate_sql="INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','$slate_plist',0,1,1,NULL,NULL);"
        ;;
      10.10)
        slate_sql="INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','$slate_plist',0,1,1,NULL);"
        ;;
    esac
    [ -n "$slate_sql" ] && sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "$slate_sql"
  fi
}

warn_installed() {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

usage() {
    echo "Usage: $0 <link|unlink|git|vim|iterm|chrome|slate>"
}

main() {
  [ -z "$1" ] && usage && exit 1

  case "$1" in
    chrome) chrome;;
    git) gitconfig;;
    iterm) iterm;;
    slate) slate;;
    link) link;;
    unlink) unlink;;
    vim) vimconfig;;
    *) usage;;
  esac
}

main $1
