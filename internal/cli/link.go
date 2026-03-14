package cli

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/colinhoglund/dotfiles/internal/config"
	"github.com/spf13/cobra"
)

func newLinkCmd(configFile *string) *cobra.Command {
	return &cobra.Command{
		Use:   "link",
		Short: "Create symlinks for dotfiles",
		RunE: func(_ *cobra.Command, _ []string) error {
			if *configFile == "" {
				return fmt.Errorf("config file required: use -c flag")
			}
			conf, err := config.New(*configFile)
			if err != nil {
				return err
			}
			return linkDotfiles(conf)
		},
	}
}

func newUnlinkCmd(configFile *string) *cobra.Command {
	return &cobra.Command{
		Use:   "unlink",
		Short: "Remove dotfile symlinks",
		RunE: func(_ *cobra.Command, _ []string) error {
			if *configFile == "" {
				return fmt.Errorf("config file required: use -c flag")
			}
			conf, err := config.New(*configFile)
			if err != nil {
				return err
			}
			return unlinkDotfiles(conf)
		},
	}
}

func linkDotfiles(conf *config.Config) error {
	for _, l := range conf.Links {
		src := filepath.Join(conf.Dir(), l.Source)

		dest, err := l.ExpandDestination()
		if err != nil {
			return err
		}

		if err := os.MkdirAll(filepath.Dir(dest), 0750); err != nil {
			return err
		}

		// Check if destination already exists
		if info, err := os.Lstat(dest); err == nil {
			if info.Mode()&os.ModeSymlink != 0 {
				// Already a symlink — remove and re-create
				os.Remove(dest)
			} else {
				// Real file or directory — back it up
				bak := dest + ".bak"
				log.Printf("backing up %s to %s", dest, bak)
				os.RemoveAll(bak)
				if err := os.Rename(dest, bak); err != nil {
					return err
				}
			}
		}

		log.Printf("linking %s -> %s", src, dest)
		if err := os.Symlink(src, dest); err != nil {
			return err
		}
	}

	return nil
}

func unlinkDotfiles(conf *config.Config) error {
	for _, l := range conf.Links {
		dest, err := l.ExpandDestination()
		if err != nil {
			return err
		}

		info, err := os.Lstat(dest)
		if err != nil {
			continue
		}

		if info.Mode()&os.ModeSymlink != 0 {
			log.Printf("removing symlink: %s", dest)
			os.Remove(dest)
		} else {
			log.Printf("skipping %s: not a symlink", dest)
		}
	}

	return nil
}
