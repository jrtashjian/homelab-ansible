provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

locals {
  minecraft_lxc = {
    "proxy" = {
      cores        = 2
      memory       = 2048
      disk_size    = 8
      groups       = ["minecraft", "minecraft-proxies"]
      node         = "pve-node02"
    }
    "lobby" = {
      cores        = 2
      memory       = 2048
      disk_size    = 8
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node03"
    }
    "main" = {
      cores        = 8
      memory       = 8192
      disk_size    = 32
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node02"
    }
    "hardcore" = {
      cores        = 8
      memory       = 8192
      disk_size    = 32
      groups       = ["minecraft", "minecraft-worlds"]
      node         = "pve-node03"
    }
  }
}

module "minecraft_lxc" {
  source = "../../modules/proxmox_container"

  for_each = local.minecraft_lxc
  pool_id  = proxmox_virtual_environment_pool.minecraft_pool.id

  node_name = each.value.node
  lxc_name  = "minecraft-${each.key}"

  cpu    = each.value.cores
  memory = each.value.memory

  disk_size = each.value.disk_size

  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key
}

# Add the LXCs to the Ansible inventory.
resource "ansible_host" "minecraft_lxc" {
  for_each = { for k, v in module.minecraft_lxc : k => v }

  name   = each.value.name
  groups = local.minecraft_lxc[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = "minecraft-${each.key}.int.jrtashjian.com"
  }
}

resource "proxmox_virtual_environment_pool" "minecraft_pool" {
  comment = "Managed by Terraform"
  pool_id = "game-minecraft"
}

