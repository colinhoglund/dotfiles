.PHONY: all
all: link git vim iterm chrome

%:
	./scripts/setup.sh $(@)
