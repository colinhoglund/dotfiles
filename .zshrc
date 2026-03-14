autoload -Uz compinit
compinit

eval "$(/usr/local/bin/brew shellenv)"
eval "$(starship init zsh)"

## env preferences ##
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:/usr/local/sbin:$HOME/.local/bin:$PATH:$HOME/bin:/usr/local/opt/go/libexec/bin"
export EDITOR=vi
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
alias diff='diff -y'

# application aliases
# alias brew to avoid pyenv config warnings https://github.com/pyenv/pyenv/issues/106
alias git-nossl='git -c http.sslVerify=false'
alias glog='git log --pretty=oneline --graph' # pretty git log graph
alias date='gdate'                            # gnu date
alias sed='gsed'                              # gnu sed
alias dd='gdd'                                # gnu dd
alias itmux='tmux -CC'                        # tmux w/ iTerm integration
alias tkill='tmux kill-session'               # kill tmux session
alias tlist='tmux list-sessions'              # list tmux sessions
alias gocov='go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out'
alias goclean='go clean -cache -testcache -modcache -fuzzcache'
