# Homelab Ansible

Automate the creation and maintenance of [my homelab infrastructure](https://jrtashjian.com/2022/10/my-homelab/).

The roles within this collection are specifically designed to work with minimal [Debian](https://www.debian.org/) Stable systems. You can either install Debian from scratch or use a preconfigured Debian installation image provided by your hosting provider.

Initialize the controller host with the following command. This step is crucial as it ensures that the 1Password CLI is installed and ready to retrieve secrets, which are then securely stored in an encrypted ansible-vault file for use with the playbooks.

```bash
sudo ./init.sh
```

## Initial setup for target hosts

To prepare your environment for Ansible, follow these steps:

### From the target console

```bash
# Update package information and install essential dependencies
apt update && apt --no-install-recommends install python3 sudo openssh-server

# Create a user account for remote administration (replace 'ansible' with your desired username)
useradd --create-home --groups sudo --shell /bin/bash ansible

# Set the sudo password for the newly created user. This should be set to the ansible_become_pass var.
passwd ansible

# Securely log out from the server console
logout
```

### From the control console

```bash
# Fetch the private key from 1Password and store it in a cache directory
op read "op://homelab/ansible-ssh/private key?ssh-format=openssh" -o ~/.ssh/ansible_ed25519

# Remove carriage-return characters which 1Password seems to output.
sed -i 's/\r//' ~/.ssh/ansible_ed25519

# Fetch the public key from 1Password and store it in a cache directory
op read "op://homelab/ansible-ssh/public key" -o ~/.ssh/ansible_ed25519.pub

# Copy the public key to the remote server's authorized_keys file for SSH key-based authentication
ssh-copy-id -i ~/.ssh/ansible_ed25519.pub ansible@123.123.123.123
```

## Running Playbooks

```bash
ansible-playbook ./playbooks/homelab.yml
```

## Running Terraform

```bash
op run --env-file="terraform/.env_vars" -- terraform -chdir=terraform/ plan
```

## Ansible Vaults

The Ansible Vault password is securely stored in the `.ansible-vault-password` file, and this file is explicitly excluded from version control by Git.

Encrypting vaults:
```
find . -type f -path '*vault.yml' -exec ansible-vault encrypt {} \;
```

Decrypting vaults:
```
find . -type f -path '*vault.yml' -exec ansible-vault decrypt {} \;
```