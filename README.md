OS X dotfiles
========
**Please note:** These dotfiles contain many tools specific to Python development

Install Xcode command line tools:

    xcode-select --install

Clone repo into home directory:

    git clone https://github.com/colinhoglund/dotfiles.git
    cd dotfiles

Deactivate any existing python virtualenvs and run installers:

    dotfiles -c config.yaml
    eval $(/opt/homebrew/bin/brew shellenv)
    brew bundle
    ~/.install.sh
    make all
    . ~/.bash_profile

youcompleteme will need to be compiled before it does anything
https://github.com/ycm-core/YouCompleteMe#macos

Optional Steps:
- Load custom iTerm2 preferences:
  - `cp com.googlecode.iterm2.plist ~/`
  - Preferences -> General -> Settings -> Load preferences from a custom folder or URL -> enter `~/`
