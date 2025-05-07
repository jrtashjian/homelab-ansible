provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

locals {
  minecraft_lxc = {
    "proxy" = {
      cores     = 2
      memory    = 2048
      disk_size = 8
      groups    = ["minecraft", "minecraft-proxies"]
      node      = "pve-node02"
    }
    "lobby" = {
      cores     = 2
      memory    = 2048
      disk_size = 8
      groups    = ["minecraft", "minecraft-worlds"]
      node      = "pve-node03"
    }
    "main" = {
      cores     = 8
      memory    = 8192
      disk_size = 32
      groups    = ["minecraft", "minecraft-worlds"]
      node      = "pve-node02"
    }
    "hardcore" = {
      cores     = 8
      memory    = 16384
      disk_size = 32
      groups    = ["minecraft", "minecraft-worlds"]
      node      = "pve-node03"
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

resource "proxmox_virtual_environment_firewall_options" "minecraft_worlds" {
  for_each = { for k, v in module.minecraft_lxc : k => v }

  node_name    = module.minecraft_lxc[each.key].node_name
  container_id = module.minecraft_lxc[each.key].id

  enabled       = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"

  dhcp          = true
  ndp           = true
  radv          = false
  macfilter     = true
  ipfilter      = false
  log_level_in  = "nolog"
  log_level_out = "nolog"
}

resource "proxmox_virtual_environment_firewall_rules" "minecraft_worlds" {
  for_each = { for k, v in module.minecraft_lxc : k => v if contains(local.minecraft_lxc[k].groups, "minecraft-worlds") }

  node_name    = module.minecraft_lxc[each.key].node_name
  container_id = module.minecraft_lxc[each.key].id

  rule {
    security_group = "ssh-server"
    iface          = "net0"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    source  = "LAN"
    comment = "Allow Java Edition"
    dport   = "25565"
    proto   = "tcp"
    iface   = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "minecraft_proxies" {
  for_each = { for k, v in module.minecraft_lxc : k => v if contains(local.minecraft_lxc[k].groups, "minecraft-proxies") }

  node_name    = module.minecraft_lxc[each.key].node_name
  container_id = module.minecraft_lxc[each.key].id

  rule {
    security_group = "ssh-server"
    iface          = "net0"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Java Edition"
    dport   = "25565"
    proto   = "tcp"
    iface   = "net0"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Bedrock Edition (TCP)"
    dport   = "19132"
    proto   = "tcp"
    iface   = "net0"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow Bedrock Edition (UDP)"
    dport   = "19132"
    proto   = "udp"
    iface   = "net0"
  }
}
