package main

import (
	"log"

	"github.com/colinhoglund/dotfiles/internal/cli"
)

func main() {
	if err := cli.New().Execute(); err != nil {
		log.Fatal(err)
	}
}
