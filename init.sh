#!/bin/bash

# Check for dependencies
if ! command -v ncftpput &> /dev/null
then
    echo "ncftpput command not found. Please install ncftp."
    exit 1
fi

if ! command -v dialog &> /dev/null
then
    echo "dialog command not found. Please install dialog."
    exit 1
fi

# Read FTP path, location, username, and password from a config file
FTP_PATH=$(grep "ftp_path=" config.txt | cut -d= -f2)
FTP_LOCATION=$(grep "ftp_location=" config.txt | cut -d= -f2)
FTP_USERNAME=$(grep "ftp_username=" config.txt | cut -d= -f2)
FTP_PASSWORD=$(grep "ftp_password=" config.txt | cut -d= -f2)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Set the folder path
folder_path=$(cd "$SCRIPT_DIR"; pwd)


# Get a list of files in the folder
files=$(ls $folder_path)

# Create the dialog window using dialog
selected_files=$(dialog --stdout \
                    --title "Select Files" \
                    --checklist "Choose files to upload:" \
                    0 0 0 \
                    $(for file in $files; do echo "$file \"$file\" off"; done))

# Copy the selected items to the FTP site
for file in $selected_files; do
  ncftpput -R -v -u $FTP_USERNAME -p $FTP_PASSWORD $FTP_LOCATION $FTP_PATH "$folder_path/$file"
done

clear

echo "Done adding $selected_files"