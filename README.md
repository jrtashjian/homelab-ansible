# Homelab Ansible

Automate the creation and maintenance of [my homelab infrastructure](https://jrtashjian.com/2022/10/my-homelab/).

The roles within this collection are specifically designed to work with minimal [Debian](https://www.debian.org/) Stable systems. You can either install Debian from scratch or use a preconfigured Debian installation image provided by your hosting provider.

Initialize the controller host with the following command. This step is crucial as it ensures that the 1Password CLI is installed and ready to retrieve secrets, which are then securely stored in an encrypted ansible-vault file for use with the playbooks.

```bash
sudo ./init.sh
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