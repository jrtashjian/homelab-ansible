provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

provider "minio" {
  minio_server = "192.168.10.11:9000"
}

resource "proxmox_virtual_environment_pool" "gitlab_pool" {
  comment = "Managed by Terraform"
  pool_id = "gitlab"
}

module "gitlab_vms" {
  source = "../../modules/proxmox_vm"

  node_name = "pve-node03"
  vm_name   = "gitlab"
  pool_id   = proxmox_virtual_environment_pool.gitlab_pool.id

  cpu       = 4
  memory    = 8192
  disk_size = 32

  cloudinit_template = "cloudinit-debian-12"

  ansible_user       = var.ansible_user
  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key
}

# Add the VMs to the Ansible inventory.
resource "ansible_host" "gitlab_vms" {
  name   = module.gitlab_vms.name
  groups = ["gitlab"]

  variables = {
    ansible_host = module.gitlab_vms.ipv4_address
  }
}

module "gitlab_runner_vms" {
  source = "../../modules/proxmox_vm"

  count     = 5
  cpu       = 6
  memory    = 4096
  disk_size = 16

  node_name = count.index % 2 == 0 ? "pve-node02" : "pve-node03"
  vm_name   = format("gitlab-runner%02d", count.index + 1)
  pool_id   = proxmox_virtual_environment_pool.gitlab_pool.id

  cloudinit_template = "cloudinit-debian-12"

  ansible_user       = var.ansible_user
  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key
}

# Add the VMs to the Ansible inventory.
resource "ansible_host" "gitlab_runner_vms" {
  for_each = { for instance in module.gitlab_runner_vms : instance.name => instance.ipv4_address }

  name   = each.key
  groups = ["gitlab-runner"]

  variables = {
    ansible_host = each.value
  }
}


resource "minio_s3_bucket" "gitlab_artifacts" {
  bucket = "gitlab-artifacts"
}

resource "minio_s3_bucket" "gitlab_ci_secure_files" {
  bucket = "gitlab-ci-secure-files"
}

resource "minio_s3_bucket" "gitlab_dependency_proxy" {
  bucket = "gitlab-dependency-proxy"
}

resource "minio_s3_bucket" "gitlab_external_diffs" {
  bucket = "gitlab-external-diffs"
}

resource "minio_s3_bucket" "gitlab_lfs" {
  bucket = "gitlab-lfs"
}

resource "minio_s3_bucket" "gitlab_packages" {
  bucket = "gitlab-packages"
}

resource "minio_s3_bucket" "gitlab_pages" {
  bucket = "gitlab-pages"
}

resource "minio_s3_bucket" "gitlab_terraform_state" {
  bucket = "gitlab-terraform-state"
}

resource "minio_s3_bucket" "gitlab_uploads" {
  bucket = "gitlab-uploads"
}
