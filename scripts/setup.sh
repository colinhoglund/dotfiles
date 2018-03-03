#!/bin/bash

[ -z "$1" ] && echo "Usage: $0 <link/unlink>"

dotfiles='.bash_profile
          .bash_prompt
          .ipython
          .slate
          .vimrc'

link() {
  for i in $dotfiles; do
    file=~/$i
    # backup existing file if it's not a soft link
    [ -e "$file" ] && [ ! -L "$file" ] \
      && rm -rf $file.bak \
      && mv $file $file.bak
    ln -fs $(pwd)/$i $file
  done
}

unlink() {
  for i in $dotfiles; do
    file=~/$i
    # only remove if it's a link
    [ -h "$file" ] && rm $file
  done
}

$1
