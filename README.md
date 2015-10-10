OS X dotfiles
========

Install Xcode command line tools:
```
xcode-select --install
```

Clone repo using the following commands:
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

Enable assitive devices for Slate:
```
https://support.apple.com/en-us/HT202866
```
