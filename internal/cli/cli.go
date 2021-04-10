package cli

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"errors"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/colinhoglund/dotfiles/internal/config"
)

func InstallRemoteFiles(rFiles ...config.RemoteFile) error {
	for _, f := range rFiles {
		if _, err := os.Stat(f.Destination); err == nil {
			log.Println("file already exists:", f.Destination)

			continue
		}

		if err := getBinary(f.URL, f.ArchiveSource, f.Destination); err != nil {
			log.Fatal(err)
		}
	}

	return nil
}

func getBinary(url, archivedFilename, filename string) error {
	log.Println("downloading:", url)

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	switch {
	case strings.HasSuffix(url, ".zip"):
		log.Println("unpacking zip archive:", url)

		if err := getZip(resp.Body, archivedFilename, filename); err != nil {
			return err
		}
	case strings.HasSuffix(url, ".tar.gz"):
		log.Println("unpacking tar.gz archive:", url)

		if err := getTar(resp.Body, archivedFilename, filename); err != nil {
			return err
		}
	case strings.HasSuffix(url, ".pkg"):
		log.Println("installing pkg:", url)

		if err := getPkg(resp.Body); err != nil {
			return err
		}
	case strings.HasSuffix(url, ".dmg"):
		// TODO:
		// hdiutil attach -nobrowse /tmp/googlechrome.dmg
		// sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
		// umount /Volumes/Google\ Chrome/
		// rm -f /tmp/googlechrome.dmg
	default:
		if err := copyFileIfNotExists(resp.Body, filename, 0755); err != nil {
			return err
		}
	}

	return nil
}

func getTar(reader io.Reader, archivedFilename, filename string) error {
	tempfile, err := copyToTempFile(reader)
	if err != nil {
		return err
	}
	defer os.Remove(tempfile)

	f, err := os.Open(tempfile)
	if err != nil {
		return err
	}

	gzReader, err := gzip.NewReader(f)
	if err != nil {
		return err
	}

	tarReader := tar.NewReader(gzReader)
	for {
		header, err := tarReader.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}

		if header.Name == archivedFilename {
			if err := copyFileIfNotExists(tarReader, filename, 0755); err != nil {
				return err
			}

			break
		}
	}

	return nil
}

func getZip(reader io.Reader, archivedFilename, filename string) error {
	tempfile, err := copyToTempFile(reader)
	if err != nil {
		return err
	}
	defer os.Remove(tempfile)

	zipreader, err := zip.OpenReader(tempfile)
	if err != nil {
		return err
	}

	var zipfile *zip.File
	for _, f := range zipreader.File {
		if f.Name == archivedFilename {
			zipfile = f
			break
		}
	}

	if zipfile == nil {
		return errors.New("file did not exist in archive")
	}

	zipfileReadCloser, err := zipfile.Open()
	if err != nil {
		return err
	}

	if err := copyFileIfNotExists(zipfileReadCloser, filename, 0755); err != nil {
		return err
	}

	return nil
}

func getPkg(reader io.Reader) error {
	tempfile, err := copyToTempFile(reader)
	if err != nil {
		return err
	}
	defer os.Remove(tempfile)

	pkgName := tempfile + ".pkg"

	// file must have a .pkg file extension
	if err := os.Rename(tempfile, pkgName); err != nil {
		return err
	}

	return execCmd("sudo", "installer", "-pkg", pkgName, "-target", "/").Run()
}

func copyFileIfNotExists(reader io.Reader, filename string, mode os.FileMode) error {
	log.Println("copying executable:", filename)

	file, err := os.OpenFile(filename, os.O_CREATE|os.O_EXCL|os.O_WRONLY, mode)
	if err != nil {
		return err
	}

	if _, err = io.Copy(file, reader); err != nil {
		return err
	}

	return nil
}

func copyToTempFile(reader io.Reader) (string, error) {
	f, err := os.CreateTemp("", "")
	if err != nil {
		return "", err
	}

	if _, err = io.Copy(f, reader); err != nil {
		return "", err
	}

	if err := f.Close(); err != nil {
		return "", err
	}

	return f.Name(), nil
}
