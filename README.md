OS X dotfiles
========
**Please note:** These dotfiles contain many tools specific to Python development

Install Xcode command line tools:

    xcode-select --install

Clone repo into home directory:

    git clone https://github.com/colinhoglund/dotfiles.git
    cd dotfiles

Deactivate any existing python virtualenvs and run installers:

    ~/.install.sh
    make all
    . ~/.bash_profile

youcompleteme will need to be compiled before it does anything
https://github.com/Valloric/YouCompleteMe#mac-os-x

Optional Steps:
- Load custom iTerm2 preferences:
  - Preferences -> General -> Load preferences from a custom folder or URL -> enter `~/`

# Go Binary Installation Method

WIP...

```
dotfiles -c config.yaml
brew bundle
```
