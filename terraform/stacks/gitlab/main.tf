provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

module "gitlab_vms" {
  source = "../../modules/proxmox_vm"

  node_name = "pve-node03"
  vm_name   = "gitlab"

  cpu       = 4
  memory    = 8192
  disk_size = 32

  cloudinit_template = "cloudinit-debian-12"

  ANSIBLE_USER       = var.ansible_user
  ANSIBLE_PASS       = var.ansible_pass
  ANSIBLE_PUBLIC_KEY = var.ansible_public_key
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

  count = 2

  node_name = count.index % 2 == 0 ? "pve-node02" : "pve-node03"
  vm_name   = format("gitlab-runner%02d", count.index + 1)

  cloudinit_template = "cloudinit-debian-12"

  ANSIBLE_USER       = var.ansible_user
  ANSIBLE_PASS       = var.ansible_pass
  ANSIBLE_PUBLIC_KEY = var.ansible_public_key
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