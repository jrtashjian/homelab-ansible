#!/usr/bin/env bash

# Check if SSH_CONNECTION environment variable is set
if [ -z "$SSH_CONNECTION" ]; then
    echo "This script must be run through an SSH connection."
    exit 1
fi

set -o errexit
set -o nounset

# Check the number of arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <ansible username> <ansible password>"
    exit 1
fi

# Update package information and install essential dependencies
apt update
apt --no-install-recommends install sudo openssh-server

# Create a user account for remote administration (replace 'ansible' with your desired username)
useradd --create-home --groups sudo --shell /bin/bash "$1"

# Set the sudo password for the newly created user
echo "$2" | passwd --stdin "$1"