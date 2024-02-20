provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true

  ssh {
    agent    = true
  }
}

locals {
  pve_nodes = {
    "pve-node02" = {
      "vmbr0" = "192.168.10.12/24"
      "vmbr1" = "192.168.30.12/24"
    }
    "pve-node03" = {
      "vmbr0" = "192.168.10.13/24"
      "vmbr1" = "192.168.30.13/24"
    }
  }
}

# vmbr0 is created during the installation of Proxmox VE.
import {
  to = proxmox_virtual_environment_network_linux_bridge.vmbr0["pve-node02"]
  id = "pve-node02:vmbr0"
}
import {
  to = proxmox_virtual_environment_network_linux_bridge.vmbr0["pve-node03"]
  id = "pve-node03:vmbr0"
}
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr0" {
  for_each  = local.pve_nodes
  node_name = each.key

  name    = "vmbr0"
  comment = "Managed by Terraform"

  ports   = ["eno2"]
  address = each.value["vmbr0"]
  gateway = "192.168.10.1"

  vlan_aware = true
}

# Create a Linux bridge for the storage network.
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  for_each  = local.pve_nodes
  node_name = each.key

  name    = "vmbr1"
  comment = "Managed by Terraform"

  ports   = ["eno3"]
  address = each.value["vmbr1"]
}
