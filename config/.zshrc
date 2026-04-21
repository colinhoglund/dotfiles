# Initialize zsh completion system
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Homebrew (auto-detect Apple Silicon vs Intel)
[[ -f /opt/homebrew/bin/brew ]] \
  && eval "$(/opt/homebrew/bin/brew shellenv)" \
  || eval "$(/usr/local/bin/brew shellenv)"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

## env preferences ##
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR=nvim

## file handling aliases ##
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ls='eza'
alias ll='eza -la --git'
alias lt='ll --tree --ignore-glob ".git"'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias diff='diff -y'
alias grep='grep --color=auto'

## editor aliases ##
alias vi='nvim'
alias vim='nvim'

## application aliases ##
alias git-nossl='git -c http.sslVerify=false'
alias glog='git log --pretty=oneline --graph'
alias date='gdate'
alias sed='gsed'
alias dd='gdd'
alias tkill='tmux kill-session'
alias tlist='tmux list-sessions'
alias gocovhtml='go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out'
alias goclean='go clean -cache -testcache -modcache -fuzzcache'
alias venv='source .venv/bin/activate'

gocov() {
  # If no args are provided, default to "./..."
  if [ "$#" -eq 0 ]; then
    set -- ./...
  fi

  go test -coverprofile=coverage.out "$@" > /dev/null 2>&1
  go tool cover -func <(cat coverage.out | grep -v -i generated) | grep total | awk '{print $1, $3}'
}

uv-activate() { source "${1:-.}/.venv/bin/activate" }

# Machine-local overrides (not tracked in repo)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
