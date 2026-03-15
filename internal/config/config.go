package config

import (
	"os"
	"path/filepath"
	"strings"

	"sigs.k8s.io/yaml"
)

type (
	Config struct {
		RemoteFiles []RemoteFile `json:"remoteFiles"`
		Links       []Link       `json:"links"`
		dir         string
	}

	RemoteFile struct {
		URL           string `json:"url"`
		Destination   string `json:"destination"`
		ArchiveSource string `json:"archiveSource"`
		AppName       string `json:"appName"`
		CheckPath     string `json:"checkPath"`
	}

	Link struct {
		Source      string `json:"source"`
		Destination string `json:"destination"`
	}
)

func New(file string) (*Config, error) {
	fileBytes, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	conf := &Config{}
	if err := yaml.Unmarshal(fileBytes, &conf); err != nil {
		return nil, err
	}

	absPath, err := filepath.Abs(file)
	if err != nil {
		return nil, err
	}

	conf.dir = filepath.Dir(absPath)

	return conf, nil
}

// Dir returns the directory containing the config file, used to resolve
// relative link source paths.
func (c *Config) Dir() string {
	return c.dir
}

func ExpandTilde(path string) (string, error) {
	if path != "~" && !strings.HasPrefix(path, "~/") {
		return path, nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, path[2:]), nil
}
