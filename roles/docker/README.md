# Docker Ansible Role

This Ansible role installs and configures Docker on Debian-based systems.

## Features

- Installs Docker CE and related components from the official repository
- Adds the official Docker APT repository and GPG key
- Enables Docker service at boot
- Grants Docker privileges to the ansible user

## Role Variables

The role uses the following Ansible facts:

- `ansible_distribution_release`: Used to determine the Debian release for the repository
- `ansible_user`: The user to add to the Docker group

## Tags

The role supports the following Ansible tags for selective execution:

- `docker-repo-install`: Force reinstallation of the Docker APT repository even if already present

## Example Playbook

```yaml
- hosts: docker-hosts
  roles:
    - role: docker
```

### Usage with Tags

- **Normal run** (idempotent): `ansible-playbook playbook.yml`
- **Force repository reinstall**: `ansible-playbook playbook.yml --tags docker-repo-install`

## Components Installed

The role installs the following Docker components:

- `docker-ce`: Docker Community Edition
- `docker-ce-cli`: Docker CLI
- `containerd.io`: Container runtime
- `docker-buildx-plugin`: Docker Buildx plugin
- `docker-compose-plugin`: Docker Compose plugin

## Configuration

- Enables the Docker service to start at boot
- Adds the ansible user to the `docker` group for privileged access
- Updates Docker components to the latest available versions
