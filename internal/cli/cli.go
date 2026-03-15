package cli

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
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

func installRemoteFiles(rFiles ...config.RemoteFile) error {
	for _, f := range rFiles {
		if isInstalled(f) {
			log.Println("already installed, skipping:", f.URL)
			continue
		}

		if f.AppName != "" {
			if err := getDmgApp(f.URL, f.AppName); err != nil {
				return err
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
			return err
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
		return getZip(resp.Body, archivedFilename, filename)
	case strings.HasSuffix(url, ".tar.gz"):
		log.Println("unpacking tar.gz archive:", url)
		return getTar(resp.Body, archivedFilename, filename)
	case strings.HasSuffix(url, ".pkg"):
		log.Println("installing pkg:", url)
		return getPkg(resp.Body)
	default:
		return copyFileIfNotExists(resp.Body, filename, 0755)
	}
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
	defer f.Close()

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
			return copyFileIfNotExists(tarReader, filename, 0755)
		}
	}

	return fmt.Errorf("file %q not found in archive", archivedFilename)
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
	defer zipreader.Close()

	for _, f := range zipreader.File {
		if f.Name == archivedFilename {
			rc, err := f.Open()
			if err != nil {
				return err
			}
			defer rc.Close()
			return copyFileIfNotExists(rc, filename, 0755)
		}
	}

	return fmt.Errorf("file %q not found in archive", archivedFilename)
}

func getPkg(reader io.Reader) error {
	tempfile, err := copyToTempFile(reader)
	if err != nil {
		return err
	}

	pkgName := tempfile + ".pkg"
	if err := os.Rename(tempfile, pkgName); err != nil {
		os.Remove(tempfile)
		return err
	}
	defer os.Remove(pkgName)

	return execCmd("sudo", "installer", "-pkg", pkgName, "-target", "/").Run()
}

func copyFileIfNotExists(reader io.Reader, filename string, mode os.FileMode) error {
	log.Println("copying executable:", filename)

	file, err := os.OpenFile(filename, os.O_CREATE|os.O_EXCL|os.O_WRONLY, mode)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = io.Copy(file, reader)
	return err
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
