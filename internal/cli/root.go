package cli

import (
	"log"
	"os"
	"os/exec"

	"github.com/colinhoglund/dotfiles/internal/config"
	"github.com/spf13/cobra"
)

type root struct {
	configFile string
}

func New() *cobra.Command {
	r := &root{}
	cmd := &cobra.Command{
		Use:   "dotfiles",
		Short: "CLI tool for managing local dev setup.",
		RunE: func(_ *cobra.Command, _ []string) error {
			return r.run()
		},
	}

	cmd.Flags().StringVarP(&r.configFile, "config-file", "c", "", "JSON/YAML configuration file")

	return cmd
}

func (r *root) run() error {
	conf, err := config.New(r.configFile)
	if err != nil {
		return err
	}

	if err := xcodeInstall(); err != nil {
		return err
	}

	log.Println("installing remote files")

	if err := InstallRemoteFiles(conf.RemoteFiles...); err != nil {
		return err
	}

	log.Println("done")

	return nil
}

func xcodeInstall() error {
	// xcode-select -p errors with exit code 2 when command line tools are not installed
	err := exec.Command("xcode-select", "-p").Run()
	if exitErr, ok := err.(*exec.ExitError); ok && exitErr.ExitCode() == 2 {
		if err := execCmd("xcode-select", "--install").Run(); err != nil {
			return err
		}
	}
	return err
}

func execCmd(name string, args ...string) *exec.Cmd {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd
}
