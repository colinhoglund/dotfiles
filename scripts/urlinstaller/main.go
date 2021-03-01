package main

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

type remoteFile struct {
	URL           string
	Destination   string
	ArchiveSource string
}

func main() {
	remoteFiles := []remoteFile{
		{
			URL:         "https://dl.k8s.io/release/v1.20.0/bin/darwin/amd64/kubectl",
			Destination: "/usr/local/bin/kubectl",
		},
		{
			URL:         "https://github.com/kubernetes/kops/releases/download/v1.18.2/kops-darwin-amd64",
			Destination: "/usr/local/bin/kops",
		},
		{
			URL:         "https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64",
			Destination: "/usr/local/bin/minikube",
		},
		{
			URL:           "https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_darwin_amd64.zip",
			Destination:   "/usr/local/bin/terraform",
			ArchiveSource: "terraform",
		},
		{
			URL:           "https://get.helm.sh/helm-v3.5.2-darwin-amd64.tar.gz",
			Destination:   "/usr/local/bin/helm",
			ArchiveSource: "darwin-amd64/helm",
		},
		{
			URL:           "https://github.com/Eneco/landscaper/releases/download/v1.0.23/landscaper-1.0.23-darwin-amd64.tar.gz",
			Destination:   "/usr/local/bin/landscaper",
			ArchiveSource: "landscaper",
		},
		//{
		//	URL: "https://dl.google.com/go/go1.16.darwin-amd64.pkg",
		//},
		//{
		//	URL: "https://desktop.docker.com/mac/stable/Docker.dmg",
		//},
	}

	for _, f := range remoteFiles {
		if _, err := os.Stat(f.Destination); err == nil {
			fmt.Println("file already exists:", f.Destination)
			continue
		}

		fmt.Println("downloading", f.URL)
		if err := getBinary(f.URL, f.ArchiveSource, f.Destination); err != nil {
			panic(err)
		}
	}
}

func getBinary(url, archivedFilename, filename string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	switch {
	case strings.HasSuffix(url, ".zip"):
		if err := getZip(resp.Body, archivedFilename, filename); err != nil {
			return err
		}
	case strings.HasSuffix(url, ".tar.gz"):
		if err := getTar(resp.Body, archivedFilename, filename); err != nil {
			return err
		}
	case strings.HasSuffix(url, ".pkg"):
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

	cmd := exec.Command("sudo", "installer", "-pkg", tempfile, "-target", "/")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
}

func copyFileIfNotExists(reader io.Reader, filename string, mode os.FileMode) error {
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
