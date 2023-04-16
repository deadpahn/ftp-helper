![Alt text](./logo.png "FTP-HELPER")

This is a command line utility that allows you to easily transfer files from a local directory to a remote FTP server. Originally designed for transferring ISOs from a NAS to a gaming console, this tool can be used for any file transfer needs.

## Features

- Uses `dialog` to provide a user-friendly interface for selecting files and folders
- Supports transferring multiple files and folders at once
- Configuration options stored in `config.txt` file

## Requirements

- `bash` shell
- `dialog` utility
- `ncftp` command line tool

## Usage

1. Clone the repository to your local machine
2. Edit the `config.txt` file to specify the FTP server details and remote directory path
3. Run `./transfer.sh` from the local directory you wish to transfer files from
4. Select the files and folders you wish to transfer using the `dialog` interface
5. Files will be transferred to the specified remote directory

## Note

The `config.txt` file is included in the repository as a template, but it is recommended to add it to your `.gitignore` file to prevent accidentally committing sensitive information.

Feel free to use, modify, and distribute this tool as needed. If you have any issues or feature requests, please submit an issue on the GitHub repository page.
