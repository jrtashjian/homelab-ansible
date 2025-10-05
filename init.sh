#!/usr/bin/env bash

set -o errexit
set -o nounset

# Colors
GREEN_BG='\033[0;42m'
RED_BG='\033[0;41m'
YELLOW_BG='\033[1;43m'
NC='\033[0m' # No Color

log() {
    echo -e "$1"
}

success() {
    echo -e "${GREEN_BG} OK ${NC} $1"
}

warn() {
    echo -e "\n${YELLOW_BG} WARN ${NC} $1\n"
}

error_exit() {
    echo -e "${RED_BG} ERROR ${NC} $1"
    exit 1
}

encrypt_vault_file() {
    local example_file=$1
    local output_file=$2

    log "Processing $output_file..."
    op inject -i $example_file -o $output_file --force > /dev/null
    ansible-vault encrypt $output_file
}

fetch_1password_item() {
    local item_path=$1
    local output_file=$2

    op read "$item_path" -o "$output_file" --force > /dev/null || error_exit "Failed to fetch $item_path"
    success "Fetched $item_path"
}

install_1password_cli() {
    # Check if 'op' command is already installed
    if ! command -v op &> /dev/null; then
        log "Installing 1Password CLI..."

        # Add the key for the 1Password apt repository
        curl -sS https://downloads.1password.com/linux/keys/1password.asc -o /tmp/1password.asc
        sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg /tmp/1password.asc

        # Add the 1Password apt repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
            sudo tee /etc/apt/sources.list.d/1password.list

        # Add the debsig-verify policy
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        sudo curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol -o /etc/debsig/policies/AC2D62742012EA22/1password.pol

        # Import debsig keyring GPG key
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        sudo gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg /tmp/1password.asc

        # Install 1Password CLI
        sudo apt update
        sudo apt install -y 1password-cli

        success "1Password CLI installed"
    else
        success "1Password CLI is already installed"
    fi
}

setup_all() {
    log "Installing Ansible Galaxy requirements..."
    ansible-galaxy install -r requirements.yml || error_exit "Failed to install Ansible Galaxy requirements"
    success "Ansible Galaxy requirements installed"
    setup_certs
    setup_vaults
}

setup_certs() {
    mkdir -p files || error_exit "Failed to create files directory"
    fetch_1password_item "op://homelab/int.jrtashjian.com.fullchain/int.jrtashjian.com.fullchain.pem" "files/fullchain.pem"
    fetch_1password_item "op://homelab/int.jrtashjian.com.privkey/int.jrtashjian.com.privkey.pem" "files/privkey.pem"
}

setup_vaults() {
    fetch_1password_item "op://homelab/ansible-user/Credentials/.ansible-vault-password" ".ansible-vault-password"
    local vault_files=(
        "group_vars/all/vault.yml"
        "group_vars/minecraft/vault.yml"
        "host_vars/sso.int.jrtashjian.com/vault.yml"
    )
    for file in "${vault_files[@]}"; do
        encrypt_vault_file "${file}.example" "$file"
    done
}

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c, --certs      Update certificates only"
    echo "  -v, --vaults     Update vaults only"
    echo "  -h, --help       Display this help"
    echo "  (no option)      Run full setup"
}

main() {
    # Default to running everything
    local run_all=true
    local run_certs=false
    local run_secrets=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--certs)
                run_all=false
                run_certs=true
                shift
                ;;
            -s|--secrets)
                run_all=false
                run_secrets=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    install_1password_cli

    # Check if 'ansible' is already installed
    if ! command -v ansible &> /dev/null
    then
        apt install -y ansible
    fi

    if $run_all; then
        setup_all
    elif $run_certs; then
        setup_certs
    elif $run_secrets; then
        setup_vaults
    fi

    success "Setup completed"
}

main "$@"