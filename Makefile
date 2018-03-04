.PHONY: all
all: link git vim chrome

%:
	./scripts/setup.sh $(@)
