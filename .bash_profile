## source bashrc ##
[ -f ~/.bashrc ] && source ~/.bashrc

## env preferences ##
PATH=$PATH:$HOME/bin
export CLICOLOR=1
export GREP_OPTIONS='--color=auto'

## file handling aliases ##
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

# application aliases
alias activate='source ./env/bin/activate'    # activate python venv
alias cssh='i2cssh'                           # cluster ssh
alias glog='git log --pretty=oneline --graph' # pretty git log graph
alias sed='gsed'                              # gnu sed
alias itmux='tmux -CC'                        # tmux w/ iTerm integration
alias tkill='tmux kill-session'               # kill tmux session
alias tlist='tmux list-sessions'              # list tmux sessions

## activate bash completion ##
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

# activate python virtualenv
[ -f ~/env/bin/activate ] && source ~/env/bin/activate
