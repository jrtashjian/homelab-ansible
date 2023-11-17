#!/usr/bin/env bash

set -o errexit
set -o nounset

# Check if the script is running with sudo privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script requires superuser privileges. Please run it with sudo."
    exit 1
fi

# Check if 'ansible' is already installed
if ! command -v ansible &> /dev/null
then
    apt update
    apt install -y ansible
fi

# Check if 'op' command is already installed
if ! command -v op &> /dev/null
then
    # Add the key for the 1Password apt repository
    curl -sS https://downloads.1password.com/linux/keys/1password.asc -o /tmp/1password.asc
    gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg /tmp/1password.asc

    # Add the 1Password apt repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list

    # Add the debsig-verify policy
    mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol -o /etc/debsig/policies/AC2D62742012EA22/1password.pol

    # Import debsig keyring GPG key
    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg /tmp/1password.asc

    # Install 1Password CLI
    apt update
    apt install -y 1password-cli
fi

# Retrieve ansible-vault password from 1Password
sudo -u $SUDO_USER op read "op://homelab/ansible-user/Credentials/.ansible-vault-password" -o .ansible-vault-password --force

# Install ansible and ansible-galaxy requirements
sudo -u $SUDO_USER ansible-galaxy install -r requirements.yml

# Run ansible playbook to fetch and encrypt secrets
sudo -u $SUDO_USER op inject -i group_vars/all/vault.yml.example -o group_vars/all/vault.yml --force
sudo -u $SUDO_USER ansible-vault encrypt group_vars/all/vault.yml