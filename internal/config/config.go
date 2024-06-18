package config

import (
	"os"

	homedir "github.com/mitchellh/go-homedir"
	"sigs.k8s.io/yaml"
)

type (
	Config struct {
		RemoteFiles []RemoteFile `json:"remoteFiles"`
	}

	RemoteFile struct {
		URL           string `json:"url"`
		Destination   string `json:"destination"`
		ArchiveSource string `json:"archiveSource"`
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

	return conf, nil
}

func (r RemoteFile) ExpandDestination() (string, error) {
	return homedir.Expand(r.Destination)
}
