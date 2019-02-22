#!/bin/bash

brew_prefix="$(dirname "$(dirname "$(command -v brew)")")"

## source bashrc ##
# shellcheck source=/dev/null
[ -f ~/.bashrc ] && source ~/.bashrc
# shellcheck source=/dev/null
[ -f ~/.bash_prompt ] && source ~/.bash_prompt

## activate iTerm2 shell integration
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

# application aliases
# alias brew to avoid pyenv config warnings https://github.com/pyenv/pyenv/issues/106
alias brew='env PATH=${PATH//$(pyenv root)\/shims:/} brew'
alias cssh='i2cssh'                           # cluster ssh
alias glog='git log --pretty=oneline --graph' # pretty git log graph
alias date='gdate'                            # gnu date
alias sed='gsed'                              # gnu sed
alias dd='gdd'                                # gnu dd
alias itmux='tmux -CC'                        # tmux w/ iTerm integration
alias tkill='tmux kill-session'               # kill tmux session
alias tlist='tmux list-sessions'              # list tmux sessions

# functions
awsprofile() {
  [ -z "$1" ] && echo "Usage: awssession <AWS_PROFILE>"
  role_arn=$(aws configure get role_arn --profile "$1")
  if [ -n "$role_arn" ]; then
    # get a session since boto doesn't support profiles with role_arn
    session=$(aws sts assume-role --profile "$1" --role-arn "$role_arn" --role-session-name "aws_${1}_session")
    AWS_PROFILE="$1"
    AWS_ACCESS_KEY_ID="$(jq -rc '.Credentials.AccessKeyId' <<< "$session")"
    AWS_SECRET_ACCESS_KEY="$(jq -rc '.Credentials.SecretAccessKey' <<< "$session")"
    AWS_SESSION_TOKEN="$(jq -c '.Credentials.SessionToken' <<< "$session")"
    AWS_SECURITY_TOKEN="$(jq -c '.Credentials.SessionToken' <<< "$session")"
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN
    export AWS_SECURITY_TOKEN
    export AWS_PROFILE
  else
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SECURITY_TOKEN
    export AWS_PROFILE="$1"
  fi
}
