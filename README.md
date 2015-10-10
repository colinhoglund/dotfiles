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

[Enable assitive devices](https://support.apple.com/en-us/HT202866) for Slate
