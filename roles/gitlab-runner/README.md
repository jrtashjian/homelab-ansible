# GitLab Runner Ansible Role

This Ansible role installs and configures GitLab Runner on Debian-based systems.

## Features

- Installs GitLab Runner from the official repository
- Configures S3-based caching using MinIO
- Sets up Docker volume mounts for containerized builds
- Includes a nightly Docker system cleanup cron job

## Role Variables

The following variables need to be defined in your inventory or group_vars:

```yaml
gitlab_runners_cache_s3:
  server_address: "{{ minio_endpoint }}"
  access_key: "{{ minio_access_key_id }}"
  secret_key: "{{ minio_secret_access_key }}"
```

## Tags

The role supports the following Ansible tags for selective execution:

- `gitlab-runner-repo-install`: Force reinstallation of the GitLab Runner APT repository even if already present

## Example Playbook

```yaml
- hosts: gitlab-runners
  roles:
    - role: gitlab-runner
```

### Usage with Tags

- **Normal run** (idempotent): `ansible-playbook playbook.yml`
- **Force repository reinstall**: `ansible-playbook playbook.yml --tags gitlab-runner-repo-install`

## Configuration

The role generates a `config.toml` file at `/tmp/config.toml` with:

- S3 cache configuration pointing to a MinIO server
- Docker runner with volume mounts for Docker socket and cache directory
- Cache bucket named `gitlab-runners-cache` in `us-east-1` region

## Handlers

- `restart gitlab_runner`: Restarts the GitLab Runner service after configuration changes

## Cron Jobs

- Daily Docker cleanup: Runs `docker system prune -f --volumes` at midnight
