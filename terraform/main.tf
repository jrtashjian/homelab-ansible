provider "proxmox" {
  endpoint = "https://192.168.10.12:8006/"
  insecure = true
}

module "docker_vms" {
  source = "./modules/proxmox_vm"

  count = 2

  node_name = "pve-node02"
  vm_name   = format("docker%02d", count.index + 1)

  cloudinit_template = "cloudinit-debian-12"

  ANSIBLE_USER       = var.ANSIBLE_USER
  ANSIBLE_PASS       = var.ANSIBLE_PASS
  ANSIBLE_PUBLIC_KEY = var.ANSIBLE_PUBLIC_KEY
}

# Add the VMs to the Ansible inventory.
resource "ansible_host" "docker_vms" {
  for_each = { for instance in module.docker_vms : instance.name => instance.ipv4_address }

  name   = each.key
  groups = ["docker"]

  variables = {
    ansible_host = each.value
  }
}

locals {
  minecraft_lxc = {
    "proxy" = {
      cores        = 2
      memory       = 2048
      ipv4_address = "192.168.10.50/24"
      groups       = ["minecraft", "minecraft-proxies"]
    }
    "lobby" = {
      cores        = 2
      memory       = 2048
      ipv4_address = "192.168.10.51/24"
      groups       = ["minecraft", "minecraft-worlds"]
    }
    "main" = {
      cores        = 8
      memory       = 8192
      ipv4_address = "192.168.10.52/24"
      groups       = ["minecraft", "minecraft-worlds"]
    }
    "hardcore" = {
      cores        = 8
      memory       = 8192
      ipv4_address = "192.168.10.53/24"
      groups       = ["minecraft", "minecraft-worlds"]
    }
  }
}

module "minecraft_lxc" {
  source = "./modules/proxmox_container"

  for_each = local.minecraft_lxc

  node_name = "pve-node02"
  lxc_name  = "minecraft-${each.key}"

  cpu    = each.value.cores
  memory = each.value.memory

  ipv4_address = each.value.ipv4_address

  ANSIBLE_PASS       = var.ANSIBLE_PASS
  ANSIBLE_PUBLIC_KEY = var.ANSIBLE_PUBLIC_KEY
}

# Add the LXCs to the Ansible inventory.
resource "ansible_host" "minecraft_lxc" {
  for_each = { for k, v in module.minecraft_lxc : k => v }

  name   = each.value.name
  groups = local.minecraft_lxc[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = each.value.ipv4_address[0]
  }
}

locals {
  cmangos_hosts = {
    "classic" = {
      cores        = 4
      memory       = 4096
      ipv4_address = "192.168.10.60/24"
      groups       = ["cmangos"]
    }
    "tbc" = {
      cores        = 4
      memory       = 4096
      ipv4_address = "192.168.10.61/24"
      groups       = ["cmangos"]
    }
    "wotlk" = {
      cores        = 4
      memory       = 4096
      ipv4_address = "192.168.10.62/24"
      groups       = ["cmangos"]
    }
  }
}

module "cmangos_hosts" {
  source = "./modules/proxmox_container"

  for_each = local.cmangos_hosts

  node_name = "pve-node02"
  lxc_name  = "cmangos-${each.key}"

  cpu    = each.value.cores
  memory = each.value.memory

  ipv4_address = each.value.ipv4_address

  ANSIBLE_PASS       = var.ANSIBLE_PASS
  ANSIBLE_PUBLIC_KEY = var.ANSIBLE_PUBLIC_KEY
}

resource "ansible_host" "cmangos_hosts" {
  for_each = { for k, v in module.cmangos_hosts : k => v }

  name   = each.value.name
  groups = local.cmangos_hosts[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = each.value.ipv4_address[0]
  }
}
