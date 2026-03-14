package cli

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/cobra"
)

func newGitCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "git",
		Short: "Configure git globals",
		RunE: func(_ *cobra.Command, _ []string) error {
			return configureGit()
		},
	}
}

func configureGit() error {
	reader := bufio.NewReader(os.Stdin)

	// Prompt for identity fields if not already set
	for _, id := range []string{"user.name", "user.email"} {
		if err := exec.Command("git", "config", "--global", id).Run(); err != nil {
			fmt.Printf("Enter git config %s: ", id)
			input, _ := reader.ReadString('\n')
			input = strings.TrimSpace(input)
			if err := execCmd("git", "config", "--global", id, input).Run(); err != nil {
				return err
			}
		}
	}

	configs := map[string]string{
		"push.default":                    "simple",
		"pull.rebase":                     "false",
		"alias.df":                        "diff",
		"alias.ci":                        "commit",
		"alias.co":                        "checkout",
		"alias.br":                        "branch",
		"alias.pl":                        "pull",
		"alias.ps":                        "push",
		"alias.st":                        "status",
		"url.git@github.com:.pushInsteadOf": "https://github.com/",
	}

	for key, val := range configs {
		if err := execCmd("git", "config", "--global", key, val).Run(); err != nil {
			return err
		}
	}

	return execCmd("git", "config", "--global", "alias.up",
		"!f() { git pull && git submodule update --init --recursive; }; f").Run()
}
