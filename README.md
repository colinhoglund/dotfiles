OS X dotfiles
========
**Please note:** These dotfiles contain many tools specific to Python development

Install Xcode command line tools:
```
xcode-select --install
```

Clone repo into home directory:
```
cd ~/
git init .
git remote add origin https://github.com/colinhoglund/dotfiles.git
git fetch
git checkout -t origin/master
```

Deactivate any existing python virtualenvs and run .install.sh script:
```
~/.install.sh
```

Optional Steps:
- Load custom iTerm2 preferences:
  - Preferences -> General -> Load preferences from a custom folder or URL -> enter `~/`
