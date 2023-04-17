#!/bin/bash
# Get the absolute path of the script
SCRIPT_PATH=$(readlink -f "$0")
# Get the base path of the script
BASE_PATH=$(dirname "$SCRIPT_PATH")
SCRIPT_NAME=$(basename "$SCRIPT_PATH")
logFile="$BASE_PATH/ftp-helper.log"
csvFile="$BASE_PATH/files.csv"
configFile="$BASE_PATH/config.txt"
jobsFile="$BASE_PATH/jobs.queue"

# make new files csv
> $csvFile
> $logFile
> $jobsFile
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
FTP_PATH=$(grep "ftp_path=" $configFile | cut -d= -f2)
FTP_LOCATION=$(grep "ftp_location=" $configFile | cut -d= -f2)
FTP_USERNAME=$(grep "ftp_username=" $configFile | cut -d= -f2)
FTP_PASSWORD=$(grep "ftp_password=" $configFile | cut -d= -f2)

# Set the folder path
folder_path=$( pwd; )
files=()
while IFS= read -r -d '' file; do
  files+=("$file" "${file//\"/\\\"}")
done < <(find "$folder_path" -maxdepth 1 \( -type f -o -type d \) -print0)

for (( i=0; i<${#files[@]}; i+=2 )); do
    file="${files[i]}"
    display_name="$(basename "${files[i+1]}")"
    echo '"'${display_name}'"' '|' '"'${file}'"' >> $csvFile
done

# Add files from CSV to the array
while IFS='|' read -r name path; do
  filesForDialog+=("$path" "$name" off)
done < "$csvFile"

# Create the dialog window using dialog
selected_files=$(dialog --stdout \
                    --title "Select Files" \
                    --no-tags \
                    --separator "|" \
                    --checklist "Choose files to upload:" \
                    0 0 0 \
                    "${filesForDialog[@]}")
clear
IFS="|"
for file in $selected_files; do
    # remove leading and trailing quotes
    file="${file%\"}"
    file="${file#\"}"
    # replace all occurrences of `\"` with `"`
    file="${file//\\\"/\"}"
    file=$(echo "$file" | sed "s/\"/'/g")
    file=$(echo "$file" | sed 's/\\\([()]\)/\1/g')

    if [[ -n "$file" ]]; then
      echo ncftpput -R -v -u "$FTP_USERNAME" -p "$FTP_PASSWORD" "$FTP_LOCATION" "$FTP_PATH" "$file" >> "$jobsFile" 2>&1
    fi
done

bash $jobsFile

rm $csvFile
rm $jobsFile

echo "
▀███▀▀▀█████▀▀██▀▀██████▀▀▀██▄       ▀███▀▀▀███████▀████▀   ▀███▀▀▀███ ▄█▀▀▀█▄█   ▀███▀▀▀██▄   ▄▄█▀▀██▄ ▀███▄   ▀███▀███▀▀▀███
  ██    ▀█▀   ██   ▀█ ██   ▀██▄        ██    ▀█ ██   ██       ██    ▀█▄██    ▀█     ██    ▀██▄██▀    ▀██▄ ███▄    █   ██    ▀█
  ██   █      ██      ██   ▄██         ██   █   ██   ██       ██   █  ▀███▄         ██     ▀███▀      ▀██ █ ███   █   ██   █
  ██▀▀██      ██      ███████          ██▀▀██   ██   ██       ██████    ▀█████▄     ██      ███        ██ █  ▀██▄ █   ██████
  ██   █      ██      ██        █████  ██   █   ██   ██     ▄ ██   █  ▄     ▀██     ██     ▄███▄      ▄██ █   ▀██▄█   ██   █  ▄
  ██          ██      ██               ██       ██   ██    ▄█ ██     ▄██     ██     ██    ▄██▀██▄    ▄██▀ █     ███   ██     ▄█
▄████▄      ▄████▄  ▄████▄           ▄████▄   ▄████▄███████████████████▀█████▀    ▄████████▀   ▀▀████▀▀ ▄███▄    ██ ▄██████████
~_~_~_~_~_~ BYE!!!
"