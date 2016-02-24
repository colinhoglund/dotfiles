#!/bin/bash

######## Checks ########

# ensure virtualenv is deactivated to avoid issues with brew
[ -n "$VIRTUAL_ENV" ]\
  && echo 'python virtualenv must be deactivated'\
  && exit 1

######## Variables ########

os_x_version=$(sw_vers | grep ProductVersion | awk '{print $2}' | cut -d. -f1,2)

brew_pkgs='
  bash-completion
  coreutils
  git
  gnu-sed
  nmap
  pyenv-virtualenvwrapper
  python
  ssh-copy-id
  the_silver_searcher
  tmux
  vim
  watch
  wget
'

git_config='
  push.default=simple
  alias.df=diff
  alias.ci=commit
  alias.co=checkout
  alias.br=branch
  alias.pl=pull
  alias.ps=push
  alias.st=status
'

# colorama 0.3.6 breaks jedi-vim for some reason...
global_python_pkgs='
  colorama==0.3.5
  pip
  pylint
  setuptools
'

venv_python_pkgs='
  colorama==0.3.5
  jupyter
  pylint
'

######## Functions ########

# warning for completed tasks
warn_installed() {
  warn_text="$(tput smul; tput setaf 3)Warning$(tput rmul; tput sgr 0):"
  echo "${warn_text} $1 already exists"
}

######## Tasks ########

# copy git configuration
[ -f ~/.gitconfig ]\
  && warn_installed ~/.gitconfig\
  || cp gitconfig .gitconfig

# setup git globals
for id in user.name user.email; do
  git config --global $id &> /dev/null
  [ "$?" -ne 0 ]\
    && echo -n "Enter a git config $id: "\
    && read input\
    && git config --global $id "$input"
done

for opt in $git_config; do
  key=`echo $opt | cut -d= -f1`
  val=`echo $opt | cut -d= -f2`
  git config --global $key $val
done

# install homebrew and packages
which brew &> /dev/null\
  && warn_installed brew\
  || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew upgrade --all
brew install $brew_pkgs

# install python dependencies
pip install --upgrade $global_python_pkgs

# setup pyenv and default virtualenv
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
  pyenv virtualenvwrapper
  if [ ! -d "${HOME}/.virtualenvs/default/" ]; then
    mkvirtualenv -p /usr/local/bin/python default
  fi
  workon default
  pip install --upgrade $venv_python_pkgs
fi

# create mkproject path
mkdir ~/code

# install molokai color scheme
mkdir -p ~/.vim/colors
[ -f ~/.vim/colors/molokai.vim ]\
  && warn_installed 'vim colorscheme: molokai'\
  || wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/colors/molokai.vim

# install powerline fonts
ls ~/Library/Fonts/ | grep -i 'for powerline' &> /dev/null
if [ $? -eq 0 ]; then
  warn_installed 'powerline fonts'
else
  git clone https://github.com/powerline/fonts.git /tmp/pl-fonts
  /tmp/pl-fonts/install.sh
  rm -rf /tmp/pl-fonts
fi

# install Vundle
[ -d ~/.vim/bundle/Vundle.vim/ ]\
  && warn_installed Vundle\
  || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# install cluster ssh
gem list | grep i2cssh &> /dev/null\
  && warn_installed i2cssh\
  || sudo gem install i2cssh

# install liquidprompt
if [ -d ~/liquidprompt/ ]; then
  warn_installed liquidprompt
else
  git clone https://github.com/nojhan/liquidprompt.git ~/liquidprompt
  cp ~/liquidprompt/liquidpromptrc-dist ~/.liquidpromptrc
fi

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
