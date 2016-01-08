## source bashrc ##
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

## env preferences ##
PATH=$PATH:$HOME/bin
export CLICOLOR=1
export GREP_OPTIONS='--color=auto'

## command aliases ##
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ll='ls -FGlhp'
alias llh='ls -FGlAhp'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias cssh='i2cssh'
alias sed='gsed'
alias glog='git log --pretty=oneline --graph'
alias activate='source ./env/bin/activate'

# tmux aliases
alias itmux='tmux -CC'
alias tkill='tmux kill-session'
alias tlist='tmux list-sessions'

## activate bash completion ##
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

# activate python virtualenv
source ~/env/bin/activate
