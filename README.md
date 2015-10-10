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

Configure git:
```
git config --global user.name "First Last"
git config --global user.email email@address
```

Additional Steps:
- [Enable assitive devices](https://support.apple.com/en-us/HT202866) for Slate
- [Install](https://www.iterm2.com/downloads.html) iTerm2
- Load iTerm2 preferences:
  - Preferences -> General -> Load preferences from a custom folder or URL
  `https://raw.githubusercontent.com/colinhoglund/dotfiles/master/com.googlecode.iterm2.plist`
