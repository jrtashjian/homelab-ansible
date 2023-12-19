provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

locals {
  minecraft_lxc = {
    "proxy" = {
      cores        = 2
      memory       = 2048
      ipv4_address = "192.168.10.50/24"
      groups       = ["minecraft", "minecraft-proxies"]
      node         = "pve-node02"
    }
    "lobby" = {
      cores        = 2
      memory       = 2048
      ipv4_address = "192.168.10.51/24"
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node03"
    }
    "main" = {
      cores        = 8
      memory       = 8192
      ipv4_address = "192.168.10.52/24"
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node02"
    }
    "hardcore" = {
      cores        = 8
      memory       = 8192
      ipv4_address = "192.168.10.53/24"
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node03"
    }
  }
}

module "minecraft_lxc" {
  source = "../../modules/proxmox_container"

  for_each = local.minecraft_lxc

  node_name = each.value.node
  lxc_name  = "minecraft-${each.key}"

  cpu    = each.value.cores
  memory = each.value.memory

  ipv4_address = each.value.ipv4_address

  ANSIBLE_PASS       = var.ansible_pass
  ANSIBLE_PUBLIC_KEY = var.ansible_public_key
}

# Add the LXCs to the Ansible inventory.
resource "ansible_host" "minecraft_lxc" {
  for_each = { for k, v in module.minecraft_lxc : k => v }

  name   = each.value.name
  groups = local.minecraft_lxc[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = each.value.ipv4_address
  }
}
