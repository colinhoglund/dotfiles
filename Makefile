.PHONY: all
all: build install brew link git godeps pydeps

.PHONY: build
build:
	go build -o dotfiles ./cmd/dotfiles

.PHONY: install
install: build
	./dotfiles -c config.yaml

.PHONY: brew
brew:
	brew bundle

.PHONY: link
link: build
	./dotfiles -c config.yaml link

.PHONY: git
git: build
	./dotfiles -c config.yaml git

.PHONY: godeps
godeps:
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/tools/gopls@latest

.PHONY: pydeps
pydeps:
	uv python install
	uv tool install ruff
