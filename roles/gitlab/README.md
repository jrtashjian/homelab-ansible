# GitLab Ansible Role

This Ansible role installs and configures GitLab CE on Debian-based systems.

## Features

- Installs GitLab CE from the official repository
- Configures GitLab with custom settings via template
- Supports SSL/TLS configuration
- Integrates with external services (LDAP, SMTP, Object Storage)

## Role Variables

The following variables need to be defined in your inventory or group_vars:

```yaml
gitlab_domain: "gitlab.example.com"
gitlab_external_url: "http://{{ gitlab_domain }}/"
gitlab_redirect_http_to_https: false
gitlab_ssl_certificate: "/etc/gitlab/ssl/{{ gitlab_domain }}.crt"
gitlab_ssl_certificate_key: "/etc/gitlab/ssl/{{ gitlab_domain }}.key"
gitlab_omniauth_providers: ""
gitlab_object_store_connection: ""
gitlab_ldap_servers: ""
gitlab_smtp: ""
gitlab_registry_storage: ""
gitlab_upgrade_version: ""  # Set to a specific version (e.g., "16.4.0-ce.0") for manual upgrades
gitlab_upgrade_version: ""  # Set to a specific version (e.g., "16.4.0-ce.0") for manual upgrades
```

## Tags

The role supports the following Ansible tags for selective execution:

- `gitlab-repo-install`: Force reinstallation of the GitLab APT repository even if already present
- `gitlab-upgrade`: Upgrade GitLab to a specific version defined by `gitlab_upgrade_version`

## Example Playbook

```yaml
- hosts: gitlab-servers
  roles:
    - role: gitlab
```

### Usage with Tags

- **Normal run** (idempotent): `ansible-playbook playbook.yml`
- **Force repository reinstall**: `ansible-playbook playbook.yml --tags gitlab-repo-install`
- **Upgrade to specific version**: `ansible-playbook playbook.yml --tags gitlab-upgrade -e gitlab_upgrade_version=16.4.0-ce.0`

## Configuration

The role generates a `gitlab.rb` configuration file at `/etc/gitlab/gitlab.rb` with settings for:

- External URL and domain configuration
- SSL/TLS certificates
- LDAP integration
- SMTP settings
- Object storage for Git LFS and registry
- Omniauth providers

## Handlers

- `restart gitlab`: Restarts the GitLab service after configuration changes