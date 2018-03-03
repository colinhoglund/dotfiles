#!/bin/bash

[ -z "$1" ] && echo "Usage: $0 <link|unlink|gitconfig>" && exit 1

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

$1
