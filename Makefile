.PHONY: all
all: shellcheck link git vim iterm chrome slate

.PHONY: shellcheck
shellcheck:
	shellcheck .bash_profile
	shellcheck .bash_prompt
	shellcheck ./scripts/setup.sh

%:
	./scripts/setup.sh $(@)
