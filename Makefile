.PHONY: all
all: shellcheck link git vim iterm chrome slate

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: brew
brew: ## Install brew packages
	brew bundle

.PHONY: shellcheck
shellcheck: ## Linter for all shell scripts
	shellcheck .bash_profile .bash_prompt ./scripts/setup.sh

%:
	./scripts/setup.sh $(@)
