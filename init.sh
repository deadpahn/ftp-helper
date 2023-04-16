#!/bin/bash

# Read FTP path, location, username, and password from a config file
FTP_PATH=$(grep "ftp_path=" config.txt | cut -d= -f2)
FTP_LOCATION=$(grep "ftp_location=" config.txt | cut -d= -f2)
FTP_USERNAME=$(grep "ftp_username=" config.txt | cut -d= -f2)
FTP_PASSWORD=$(grep "ftp_password=" config.txt | cut -d= -f2)

# Set the folder path
folder_path=$(cd "$(dirname "$0")"; pwd)

# Get a list of files in the folder
files=$(ls $folder_path)

# Create the dialog window using zenity
selected_files=$(zenity --list \
                    --title="Select Files" \
                    --multiple \
                    --column="Files" \
                    $files)

# Print the selected files
# echo "Selected files: $folder_path/$selected_files"

# Copy the selected items to the FTP site
if [ -d "$folder_path/$selected_files" ]; then
    echo "copying $folder_path/$selected_files to $FTP_LOCATION$FTP_PATH";
    ftp -i -n -d <<EOF
    open $FTP_LOCATION
    user $FTP_USERNAME $FTP_PASSWORD
    cd $FTP_PATH
    epsv off
    quit
EOF
    lftp -e "mirror --reverse $folder_path/$selected_files; quit" -u $FTP_USERNAME,$FTP_PASSWORD $FTP_PATH/$FTP_LOCATION
else
    echo "copying $folder_path/$selected_files to $FTP_LOCATION$FTP_PATH";
    ftp -i -n -d <<EOF
    open $FTP_LOCATION
    user $FTP_USERNAME $FTP_PASSWORD
    cd $FTP_PATH
    epsv off
    put "$folder_path/$selected_files" "$FTP_PATH/$selected_files"
    quit
EOF
fi
