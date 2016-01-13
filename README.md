OS X dotfiles
========

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

Run .install script:
```
./.install.sh
```

Optional Steps:
- Load iTerm2 preferences:
  - Preferences -> General -> Load preferences from a custom folder or URL -> enter `~/`
- Show parent directory for liquidprompt Python virtualenv
```
LP_VENV=" [${LP_COLOR_VIRTUALENV}$(echo ${VIRTUAL_ENV}|awk -F/ '{OFS = "/"}{print $(NF-1),$(NF)}')${NO_COL}]"
```
