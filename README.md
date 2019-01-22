OS X dotfiles
========
**Please note:** These dotfiles contain many tools specific to Python development

Install Xcode command line tools:

    xcode-select --install
    sudo installer -pkg $(find /Library/Developer/CommandLineTools/Packages/ -name 'macOS_SDK_headers_for_macOS*') -target /

Clone repo into home directory:

    git clone https://github.com/colinhoglund/dotfiles.git
    cd dotfiles
    make all
    . ~/.bash_profile

Deactivate any existing python virtualenvs and run .install.sh script:

    ~/.install.sh

youcompleteme will need to be compiled before it does anything
https://github.com/Valloric/YouCompleteMe#mac-os-x

Optional Steps:
- Load custom iTerm2 preferences:
  - Preferences -> General -> Load preferences from a custom folder or URL -> enter `~/`
