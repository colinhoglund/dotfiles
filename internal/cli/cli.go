package cli

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/colinhoglund/dotfiles/internal/config"
)

func InstallRemoteFiles(rFiles ...config.RemoteFile) error {
	for _, f := range rFiles {
		if isInstalled(f) {
			log.Println("already installed, skipping:", f.URL)
			continue
		}

		if f.AppName != "" {
			if err := getDmgApp(f.URL, f.AppName); err != nil {
				log.Fatal(err)
			}
			continue
		}

		dest, err := f.ExpandDestination()
		if err != nil {
			return err
		}

		if err := os.MkdirAll(filepath.Dir(dest), 0750); err != nil {
			return err
		}

		if err := getBinary(f.URL, f.ArchiveSource, dest); err != nil {
			log.Fatal(err)
		}
	}

	return nil
}

func isInstalled(f config.RemoteFile) bool {
	if f.CheckPath != "" {
		if _, err := exec.LookPath(f.CheckPath); err == nil {
			return true
		}
		if _, err := os.Stat(f.CheckPath); err == nil {
			return true
		}
	}
	if f.AppName != "" {
		_, err := os.Stat("/Applications/" + f.AppName)
		return err == nil
	}
	if f.Destination != "" {
		dest, err := f.ExpandDestination()
		if err != nil {
			return false
		}
		_, err = os.Stat(dest)
		return err == nil
	}
	return false
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
	default:
		if err := copyFileIfNotExists(resp.Body, filename, 0755); err != nil {
			return err
		}
	}

	return nil
}

func getDmgApp(url, appName string) error {
	log.Println("downloading:", url)

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	tmpFile, err := os.CreateTemp("", "dotfiles-*.dmg")
	if err != nil {
		return err
	}
	tmpPath := tmpFile.Name()
	defer os.Remove(tmpPath)

	if _, err := io.Copy(tmpFile, resp.Body); err != nil {
		return err
	}
	tmpFile.Close()

	mountpoint, err := os.MkdirTemp("", "dotfiles-mount-")
	if err != nil {
		return err
	}
	defer os.RemoveAll(mountpoint)

	log.Println("mounting dmg")
	if err := execCmd("hdiutil", "attach", "-nobrowse", "-mountpoint", mountpoint, tmpPath).Run(); err != nil {
		return err
	}
	defer execCmd("hdiutil", "detach", mountpoint).Run()

	// Look for the .app directly in the mountpoint, then one level deep
	appPath := filepath.Join(mountpoint, appName)
	if _, err := os.Stat(appPath); err != nil {
		matches, globErr := filepath.Glob(filepath.Join(mountpoint, "*", appName))
		if globErr != nil || len(matches) == 0 {
			return fmt.Errorf("could not find %s in mounted DMG", appName)
		}
		appPath = matches[0]
	}

	log.Println("installing:", "/Applications/"+appName)
	return execCmd("sudo", "ditto", appPath, "/Applications/"+appName).Run()
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
