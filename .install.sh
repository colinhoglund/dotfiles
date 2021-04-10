#!/bin/bash

######## Variables ########

python_version='3.7.4'

global_python_pkgs='
  awscli
  flake8
  jupyter
  pep8
  pip
  pylint
  python-language-server
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

chsh -s /bin/bash

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
