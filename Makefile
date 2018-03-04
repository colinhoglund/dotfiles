.PHONY: all
all: link git vim iterm chrome slate

%:
	./scripts/setup.sh $(@)
