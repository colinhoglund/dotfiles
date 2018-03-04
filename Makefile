.PHONY: all
all: link git vim

%:
	./scripts/setup.sh $(@)
