package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// ConfigItem represents each entry in the JSON config
type ConfigItem struct {
	Path   string `json:"path"`
	Target string `json:"target"`
}

// UnmarshallJson unmarshals the JSON string into a list of ConfigItems
func UnmarshallJson(jsonString string) ([]ConfigItem, error) {
	var configList []ConfigItem
	err := json.Unmarshal([]byte(jsonString), &configList)
	if err != nil {
		return nil, err
	}
	return configList, nil
}

// ExpandTilde expands the tilde (~) to the user's home directory
func ExpandTilde(p string) string {
	// If the path starts with '~', expand it to the home directory
	if strings.HasPrefix(p, "~") {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			fmt.Println("Error getting home directory:", err)
			return p // return the original path if error occurs
		}
		return homeDir + p[1:] // replace '~' with the home directory
	}
	return p
}

// PathCheck returns the absolute path for a given path string
func PathCheck(p string) (string, error) {
	// Expand ~ before getting the absolute path
	expandedPath := ExpandTilde(p)

	// Get the absolute path
	path, err := filepath.Abs(expandedPath)
	fmt.Println("Checking path:", p, "=>", path)
	if err != nil {
		return "", err
	}
	return path, nil
}

// ReadFile reads a file's contents and returns it as a string
func ReadFile(filename string) string {
	fileContent, err := os.ReadFile(filename)
	if err != nil {
		fmt.Println("Error reading file:", err)
		os.Exit(1)
	}
	return string(fileContent)
}

// IsDirectory checks if the given path is a directory
func IsDirectory(path string) (bool, error) {
	info, err := os.Stat(path)
	if err != nil {
		return false, err
	}
	return info.IsDir(), nil
}

// CopyFile copies a single file from source to destination
func CopyFile(source string, dest string) bool {
	// Run the cp command for files
	command := exec.Command("cp", "-f", source, dest)
	output, err := command.CombinedOutput()

	if err != nil {
		fmt.Printf("Error executing command: %v\n", err)
		fmt.Println(string(output)) // Output from stderr or stdout
		return false
	}
	return true
}

// CopyDirectory copies a directory recursively from source to destination
func CopyDirectory(source string, dest string) bool {
	// Run the cp command for directories
	command := exec.Command("cp", "-r", "-f", source, dest)
	output, err := command.CombinedOutput()

	if err != nil {
		fmt.Printf("Error executing command: %v\n", err)
		fmt.Println(string(output)) // Output from stderr or stdout
		return false
	}
	return true
}

// Copy copies the source directory/files to the destination directory
func Copy(source string, dest string) bool {
	// Ensure that source and destination paths are absolute paths
	sourceAbs, err := filepath.Abs(source)
	if err != nil {
		fmt.Println("Error getting absolute source path:", err)
		return false
	}

	destAbs, err := filepath.Abs(dest)
	if err != nil {
		fmt.Println("Error getting absolute destination path:", err)
		return false
	}

	// Ensure source and destination are not the same directory
	if sourceAbs == destAbs {
		fmt.Println("Source and destination are the same, skipping copy.")
		return false
	}

	// Ensure the destination path has a trailing slash if it's a directory
	if !strings.HasSuffix(dest, "/") {
		dest += "/"
	}

	// Check if source is a directory or a file
	isDir, err := IsDirectory(source)
	if err != nil {
		fmt.Println("Error checking if source is a directory:", err)
		return false
	}

	// Perform the copy operation based on whether the source is a file or directory
	if isDir {
		fmt.Println("Copying directory from", source, "to", dest)
		return CopyDirectory(source, dest)
	} else {
		fmt.Println("Copying file from", source, "to", dest)
		return CopyFile(source, dest)
	}
}

func main() {
	// Read the JSON file content
	dotFile := "./dot.json"
	jsonContent := ReadFile(dotFile)

	// Unmarshal the JSON content into locations
	locations, err := UnmarshallJson(jsonContent)
	if err != nil {
		fmt.Println("Error unmarshalling JSON:", err)
		return
	}

	// Process each location from the JSON
	for _, loc := range locations {
		fmt.Println("Processing:", loc.Path)

		var dest string
		var target string

		// Handle the special case for "config" target
		if loc.Target == "config" {
			dest, err = PathCheck("./config/")
			if err != nil {
				fmt.Println("Error with config path:", err)
				return
			}
		}
    if loc.Target == "home" {
			dest, err = PathCheck("./home/")
			if err != nil {
				fmt.Println("Error with home path:", err)
				return
			}
		}

		// Handle regular target path
		target, err = PathCheck(loc.Path)
		if err != nil {
			fmt.Println("Error with target path:", err)
			return
		}

		// Perform the copy operation
		if !Copy(target, dest) {
			fmt.Println("Copy failed for target:", target, "to destination:", dest)
			return
		}
	}

	// All operations were successful
	fmt.Println("All locations processed successfully!")
}

