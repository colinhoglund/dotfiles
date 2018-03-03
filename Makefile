.PHONY: all
all: link gitconfig vim

.PHONY: link
link:
	./scripts/setup.sh link

.PHONY: unlink
unlink:
	./scripts/setup.sh unlink

.PHONY: gitconfig
gitconfig:
	./scripts/setup.sh gitconfig

.PHONY: vim
vim:
	./scripts/setup.sh vim
