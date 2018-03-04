.PHONY: all
all: shellcheck link git vim iterm chrome slate

.PHONY: shellcheck
shellcheck:
	which shellcheck >/dev/null || brew install shellcheck
	shellcheck ./scripts/setup.sh

%:
	./scripts/setup.sh $(@)
