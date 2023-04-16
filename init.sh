#!/bin/bash

# Read FTP path, location, username, and password from a config file
FTP_PATH=$(grep "ftp_path=" config.txt | cut -d= -f2)
FTP_LOCATION=$(grep "ftp_location=" config.txt | cut -d= -f2)
FTP_USERNAME=$(grep "ftp_username=" config.txt | cut -d= -f2)
FTP_PASSWORD=$(grep "ftp_password=" config.txt | cut -d= -f2)

# Define the working directory
WORKING_DIR=$(pwd)

# Create an array to store the selected items
SELECTED_ITEMS=()

# Use DIALOG to create a multi-select prompt
while true; do
    # Get the list of items in the working directory
    ITEMS=$(ls -1 $WORKING_DIR)

    # Create an array of menu items
    MENU_ITEMS=()
    for ITEM in $ITEMS; do
        if [ -d "$WORKING_DIR/$ITEM" ]; then
            MENU_ITEMS+=("$ITEM" "Folder")
        else
            MENU_ITEMS+=("$ITEM" "File")
        fi
    done

    # Show the menu and store the selected items
    SELECTED=$(dialog --stdout --checklist "Select items to copy:" 0 0 0 "${MENU_ITEMS[@]}")
    if [ -n "$SELECTED" ]; then
        SELECTED_ITEMS=($SELECTED)
    else
        break
    fi
done

# Copy the selected items to the FTP site
for ITEM in "${SELECTED_ITEMS[@]}"; do
    if [ -d "$WORKING_DIR/$ITEM" ]; then
        ftp -i -n <<EOF
        open $FTP_PATH
        user $FTP_USERNAME $FTP_PASSWORD
        cd $FTP_LOCATION
        mkdir "$ITEM"
        cd "$ITEM"
        quit
EOF
        lftp -e "mirror --reverse $WORKING_DIR/$ITEM $ITEM; quit" -u $FTP_USERNAME,$FTP_PASSWORD $FTP_PATH/$FTP_LOCATION
    else
        ftp -i -n <<EOF
        open $FTP_PATH
        user $FTP_USERNAME $FTP_PASSWORD
        cd $FTP_LOCATION
        put "$WORKING_DIR/$ITEM" "$ITEM"
        quit
EOF
    fi
done

# Show a message to indicate that the copy process is complete
dialog --msgbox "Copy process complete." 0 0
