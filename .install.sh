#!/bin/bash

######## Variables ########

os_x_version=$(sw_vers | grep ProductVersion | awk '{print $2}' | cut -d. -f1,2)
python_version='2.7.13'

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

# install slate window manager
if [ -d /Applications/Slate.app ]; then
  warn_installed Slate
else
  $(curl -s http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications/)
  # enable assistive devices
  slate_plist=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' /Applications/Slate.app/Contents/Info.plist)
  case "$os_x_version" in
    10.11)
      slate_sql="INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','$slate_plist',0,1,1,NULL,NULL);"
      ;;
    10.10)
      slate_sql="INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','$slate_plist',0,1,1,NULL);"
      ;;
  esac
  [ -n "$slate_sql" ] && sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "$slate_sql"
fi

# install iTerm2
if [ -d /Applications/iTerm.app/ ]; then
  warn_installed iTerm
else
  iterm_url=$(curl -s https://www.iterm2.com/downloads.html\
              | grep -o 'https://iterm2.com/downloads/stable/.*zip'\
              | head -1)
  iterm_zipfile=$(basename $iterm_url)

  cd /tmp
  wget $iterm_url
  unzip -qd /Applications/ $iterm_zipfile
  rm -f $iterm_zipfile
fi

# install chrome
if [ -d /Applications/Google\ Chrome.app/ ]; then
  warn_installed 'Google Chrome'
else
  cd /tmp
  wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
  hdiutil attach -nobrowse /tmp/googlechrome.dmg
  sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
  umount /Volumes/Google\ Chrome/
  rm -f /tmp/googlechrome.dmg
fi
