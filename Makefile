.PHONY: all
all: gitconfig link

.PHONY: link
link:
	./scripts/setup.sh link

.PHONY: unlink
unlink:
	./scripts/setup.sh unlink

.PHONY: gitconfig
gitconfig:
	./scripts/setup.sh gitconfig
