.PHONY: all
all: link gitconfig vim

%:
	./scripts/setup.sh $(@)
