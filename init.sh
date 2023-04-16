#!/bin/bash

csvFile="files.csv"
# make new files csv
> $csvFile

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

#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#echo "The script you are running has basename $( basename -- "$0"; ), dirname $( dirname -- "$0"; )";
#echo "The present working directory is $( pwd; )";

# Set the folder path
folder_path=$( pwd; )
files=()
while IFS= read -r -d '' file; do
  files+=("$file" "${file//\"/\\\"}")
done < <(find "$folder_path" -maxdepth 1 \( -type f -o -type d \) -print0)

for (( i=0; i<${#files[@]}; i+=2 )); do
    file="${files[i]}"
    display_name="$(basename "${files[i+1]}")"
    echo '"'${display_name}'"' '|' '"'${file}'"' >> files.csv
done

# Add files from CSV to the array
while IFS='|' read -r name path; do
  filesForDialog+=("$name" "$path" off)
done < "$csvFile"

# Print the contents of the files array
#printf '%s\n' "${filesForDialog[@]}"
#exit
# Create the dialog window using dialog
selected_files=$(dialog --stdout \
                    --title "Select Files" \
                    --checklist "Choose files to upload:" \
                    0 0 0 \
                    "${filesForDialog[@]}")

# Copy the selected items to the FTP site
for file in $selected_files; do
  ncftpput -R -v -u $FTP_USERNAME -p $FTP_PASSWORD $FTP_LOCATION $FTP_PATH "$folder_path/$file"
done

clear

echo "Done adding $selected_files"