package main

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"errors"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"

	"sigs.k8s.io/yaml"
)

type remoteFile struct {
	URL           string `json:"url"`
	Destination   string `json:"destination"`
	ArchiveSource string `json:"archiveSource"`
}

type config struct {
	RemoteFiles []remoteFile `json:"remoteFiles"`
}

func main() {
	fileBytes, err := os.ReadFile(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	c := &config{}
	if err := yaml.Unmarshal(fileBytes, c); err != nil {
		log.Fatal(err)
	}

	for _, f := range c.RemoteFiles {
		if _, err := os.Stat(f.Destination); err == nil {
			log.Println("file already exists:", f.Destination)

			continue
		}

		if err := getBinary(f.URL, f.ArchiveSource, f.Destination); err != nil {
			log.Fatal(err)
		}
	}
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
		//hdiutil attach -nobrowse /tmp/googlechrome.dmg
		//sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
		//umount /Volumes/Google\ Chrome/
		//rm -f /tmp/googlechrome.dmg
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

	if err := os.Rename(tempfile, pkgName); err != nil {
		return err
	}

	cmd := exec.Command("sudo", "installer", "-pkg", pkgName, "-target", "/")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
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
