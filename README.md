OS X dotfiles
========

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
