#!/bin/bash

export BASH_SILENCE_DEPRECATION_WARNING=1

brew_prefix="$(dirname "$(dirname "$(command -v brew)")")"

## source bashrc ##
# shellcheck source=/dev/null
[ -f ~/.bashrc ] && source ~/.bashrc
# shellcheck source=/dev/null
[ -f ~/.bash_prompt ] && source ~/.bash_prompt

## activate iTerm2 shell integration
function iterm2_print_user_vars() {
  iterm2_set_user_var awsProfile "$AWS_PROFILE"
  # slow but can't find a better solution :(
  iterm2_set_user_var pythonVirtualenv "$(pyenv version-name)"
  # this command is kind of ugly, but faster than multiple kubectl calls
  iterm2_set_user_var kubeContext "$(kubectl config get-contexts | grep '^\*' | awk '{print $2" : "$5}')"
}
# shellcheck source=/dev/null
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

## activate bash completion ##
# shellcheck source=/dev/null
[ -f "${brew_prefix}/etc/bash_completion" ] && source "${brew_prefix}/etc/bash_completion"

## activate pyenv ##
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if command -v pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if command -v pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

## env preferences ##
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:/usr/local/sbin:$PATH:$HOME/bin:/usr/local/opt/go/libexec/bin"
export EDITOR=vi
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
alias diff='diff -y'

# application aliases
# alias brew to avoid pyenv config warnings https://github.com/pyenv/pyenv/issues/106
alias brew='env PATH=${PATH//$(pyenv root)\/shims:/} brew'
alias git-nossl='git -c http.sslVerify=false'
alias glog='git log --pretty=oneline --graph' # pretty git log graph
alias date='gdate'                            # gnu date
alias sed='gsed'                              # gnu sed
alias dd='gdd'                                # gnu dd
alias itmux='tmux -CC'                        # tmux w/ iTerm integration
alias tkill='tmux kill-session'               # kill tmux session
alias tlist='tmux list-sessions'              # list tmux sessions
alias gocov='go test -coverprofile=coverage.out && go tool cover -html=coverage.out'

# functions
awsprofile() {
  unset AWS_PROFILE AWS_ACCESS_KEY AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
  export AWS_PROFILE="$1"
  eval "$(aws sts assume-role --profile sso \
    --role-session-name "$(whoami)" \
    --role-arn "$(aws configure get role_arn --profile "$1")" \
    | jq -r '.Credentials |"
      export AWS_ACCESS_KEY=\(.AccessKeyId)
      export AWS_ACCESS_KEY_ID=\(.AccessKeyId)
      export AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)
      export AWS_SESSION_TOKEN=\(.SessionToken)"
    '
  )"
}
