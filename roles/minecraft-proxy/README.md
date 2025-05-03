# Minecraft Proxy Role

This Ansible role sets up a [Velocity](https://papermc.io/software/velocity)-based Minecraft proxy server with [Geyser](https://geysermc.org/download?project=geyser) and [Floodgate](https://geysermc.org/download?project=floodgate) for cross-platform play.

## Tag Usage Guide

This role provides the following tags:

### software_update
Updates the server software and plugins only.
- Downloads latest [Velocity](https://papermc.io/software/velocity) build and plugins
- Restarts the server after updating

```bash
ansible-playbook -i inventory playbook.yml --tags "software_update"
```

### config_update
Updates configuration files only.
- Updates the Velocity configuration
- Updates systemd service file

```bash
ansible-playbook -i inventory playbook.yml --tags "config_update"
```

### permissions
Fixes ownership and permissions for Minecraft directories.

```bash
ansible-playbook -i inventory playbook.yml --tags "permissions"
```