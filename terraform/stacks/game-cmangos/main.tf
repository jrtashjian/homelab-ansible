provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

locals {
  cmangos_hosts = {
    "classic" = {
      cores        = 2
      memory       = 4096
      ipv4_address = "192.168.10.60"
      ipv4_cidr    = "24"
      groups       = ["cmangos"]
      node         = "pve-node02"
    }
    "tbc" = {
      cores        = 2
      memory       = 4096
      ipv4_address = "192.168.10.61"
      ipv4_cidr    = "24"
      groups       = ["cmangos"]
      node         = "pve-node03"
    }
    "wotlk" = {
      cores        = 2
      memory       = 4096
      ipv4_address = "192.168.10.62"
      ipv4_cidr    = "24"
      groups       = ["cmangos"]
      node         = "pve-node03"
    }
  }
}

module "cmangos_hosts" {
  source = "../../modules/proxmox_container"

  for_each = local.cmangos_hosts
  pool_id  = proxmox_virtual_environment_pool.cmangos_pool.id

  node_name = each.value.node
  lxc_name  = "cmangos-${each.key}"

  cpu    = each.value.cores
  memory = each.value.memory

  ipv4_address = format("%s/%s", each.value.ipv4_address, each.value.ipv4_cidr)
  ipv4_gateway = "192.168.10.1"

  ansible_pass       = var.ansible_pass
  ansible_public_key = var.ansible_public_key
}

resource "ansible_host" "cmangos_hosts" {
  for_each = { for k, v in module.cmangos_hosts : k => v }

  name   = each.value.name
  groups = local.cmangos_hosts[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = local.cmangos_hosts[each.key].ipv4_address
  }
}

resource "proxmox_virtual_environment_pool" "cmangos_pool" {
  comment = "Managed by Terraform"
  pool_id = "game-cmangos"
}
