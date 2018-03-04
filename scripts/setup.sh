#!/bin/bash

[ -z "$1" ] \
  && funcs=$(grep '^[a-zA-Z0-9]*()' scripts/setup.sh | cut -d\( -f1 | xargs | sed 's/ /|/g') \
  && echo "Usage: $0 <${funcs}>" \
  && exit 1

links='.bash_profile
       .bash_prompt
       .ipython
       .slate
       .vimrc'

git_config='push.default=simple
            alias.df=diff
            alias.ci=commit
            alias.co=checkout
            alias.br=branch
            alias.pl=pull
            alias.ps=push
            alias.st=status'

gitconfig() {
  # setup git globals
  for id in user.name user.email; do
    git config --global $id &> /dev/null
    [ "$?" -ne 0 ]\
      && echo -n "Enter a git config $id: "\
      && read input\
      && git config --global $id "$input"
  done

  for opt in $git_config; do
    key=`echo $opt | cut -d= -f1`
    val=`echo $opt | cut -d= -f2`
    git config --global $key $val
  done
  git config --global alias.up "!f() { git pull && git submodule update --init --recursive; }; f"
}

vim() {
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

warn_installed() {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

$1
