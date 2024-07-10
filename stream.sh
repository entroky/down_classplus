#!/bin/bash

# Function to install youtube-dl
install_youtube_dl() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "Installing youtube-dl..."
    brew install youtube-dl
}

# Check if youtube-dl is installed
if ! command -v youtube-dl &> /dev/null; then
    install_youtube_dl
fi

# Prompt the user for the output directory using a dialog box
output_dir=$(osascript -e 'tell application "Finder" to set output_dir to POSIX path of (choose folder with prompt "Select Output Directory")' 2>/dev/null)
if [ -z "$output_dir" ]; then
    echo "No directory selected. Exiting script."
    exit 1
fi

# Ensure the output directory exists
if [ ! -d "$output_dir" ]; then
    echo "Creating output directory..."
    mkdir -p "$output_dir"
fi

file_count=0

while true; do
    read -p "Enter the URL of the video: " url
    if [ -z "$url" ]; then
        echo "No URL entered. Exiting script."
        exit 1
    fi

    # Basic URL validation
    if ! [[ "$url" =~ ^https?:// ]]; then
        echo "Invalid URL. Please enter a valid URL."
        continue
    fi

    read -p "Enter a custom name for the output file (press Enter to use default): " file_name

    if [ -z "$file_name" ]; then
        output_file="${output_dir}/file_${file_count}.mp4"
    else
        output_file="${output_dir}/${file_name}.mp4"
    fi

    # Ensure unique file names
    while [ -e "$output_file" ]; do
        ((file_count++))
        if [ -z "$file_name" ]; then
            output_file="${output_dir}/file_${file_count}.mp4"
        else
            output_file="${output_dir}/${file_name}_${file_count}.mp4"
        fi
    done

    # Download video using youtube-dl
    youtube-dl -f best -o "$output_file" "$url"

    echo "Video extraction complete. Output file: $output_file"

    read -p "Do you want to extract another video? (Y/N): " continue
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo "All extractions complete. The following files were extracted:"
        ls -1 "$output_dir"
        echo "Exiting script."
        break
    fi
done
