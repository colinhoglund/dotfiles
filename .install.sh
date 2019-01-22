#!/bin/bash

######## Variables ########

python_version='3.7.2'

brew_pkgs='
  bash-completion
  coreutils
  git
  gnu-sed
  gnu-tar
  httpie
  nmap
  pyenv-virtualenv
  python
  readline
  ssh-copy-id
  the_silver_searcher
  tree
  tmux
  watch
  wget
'

global_python_pkgs='
  awscli
  flake8
  jupyter
  pep8
  pip
  pylint
  setuptools
  virtualenv
'

######## Functions ########

# warning for completed tasks
warn_installed() {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

######## Tasks ########

# setup pyenv and deactivate virtualenv before running brew
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  pyenv global system
  pyenv deactivate
fi

# install homebrew and packages
which brew > /dev/null\
  && warn_installed brew\
  || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew upgrade --all
brew install $brew_pkgs

# setup pyenv and global virtualenv
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  if ! pyenv virtualenvs | grep global > /dev/null; then
    PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install $python_version
    pyenv virtualenv $python_version global
  fi

  # install/upgrade global python packages
  pyenv global global
  pyenv activate global
  [ "$(basename $PYENV_VIRTUAL_ENV)" == 'global' ] && pip install --upgrade $global_python_pkgs
fi

# install cluster ssh
gem list | grep i2cssh &> /dev/null\
  && warn_installed i2cssh\
  || sudo gem install i2cssh
