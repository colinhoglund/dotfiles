package config

type (
	Config struct {
		BrewPackages []string     `json:"brewPackages"`
		RemoteFiles  []RemoteFile `json:"remoteFiles"`
	}

	RemoteFile struct {
		URL           string `json:"url"`
		Destination   string `json:"destination"`
		ArchiveSource string `json:"archiveSource"`
	}
)

func New() Config {
	return Config{}
}
