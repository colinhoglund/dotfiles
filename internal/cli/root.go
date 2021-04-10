package cli

import (
	"log"
	"os"
	"os/exec"

	"github.com/colinhoglund/dotfiles/internal/config"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func New() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "dotfiles",
		Short: "CLI tool for managing local dev setup.",
		RunE:  runE,
	}

	cmd.Flags().StringP("config-file", "c", "", "JSON/YAML configuration file")
	_ = viper.BindPFlag("config-file", cmd.Flags().Lookup("config-file"))

	return cmd
}

func runE(cmd *cobra.Command, args []string) error {
	conf, err := config.New(viper.GetString("config-file"))
	if err != nil {
		return err
	}

	log.Println("running brew bundle")

	if err := execCmd("brew", "bundle").Run(); err != nil {
		return err
	}

	log.Println("installing remote files")

	if err := InstallRemoteFiles(conf.RemoteFiles...); err != nil {
		return err
	}

	log.Println("done")

	return nil
}

func execCmd(name string, args ...string) *exec.Cmd {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd
}
