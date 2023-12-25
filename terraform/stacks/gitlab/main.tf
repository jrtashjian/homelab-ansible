provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
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
  memory    = 2048
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
