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

# Upload wildcard certificate and private key.
resource "proxmox_virtual_environment_certificate" "int_jrtashjian_com" {
  for_each  = local.pve_nodes
  node_name = each.key

  certificate = trimspace(var.int_jrtashjian_com_cert)
  private_key = trimspace(var.int_jrtashjian_com_key)
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

# Create DMZ VLAN.
resource "proxmox_virtual_environment_network_linux_vlan" "dmz" {
  for_each = local.pve_nodes

  node_name = each.key
  name      = "vlan_dmz"

  interface = "vmbr0"
  vlan      = 66
  comment   = "DMZ"
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

# Add firewall aliases.
resource "proxmox_virtual_environment_firewall_alias" "lan_network" {
  name    = "LAN"
  cidr    = "192.168.10.0/24"
  comment = "Managed by Terraform"
}
resource "proxmox_virtual_environment_firewall_alias" "dmz_network" {
  name    = "DMZ"
  cidr    = "192.168.66.0/24"
  comment = "Managed by Terraform"
}
resource "proxmox_virtual_environment_firewall_alias" "opt1_network" {
  name    = "OPT1"
  cidr    = "192.168.20.0/24"
  comment = "Managed by Terraform"
}
resource "proxmox_virtual_environment_firewall_alias" "opt2_network" {
  name    = "OPT2"
  cidr    = "192.168.30.0/24"
  comment = "Managed by Terraform"
}

# By default, certain network traffic is still permitted at the datacenter level.
# For more details, see: https://pve.proxmox.com/pve-docs/chapter-pve-firewall.html#_datacenter_incoming_outgoing_drop_reject
resource "proxmox_virtual_environment_cluster_firewall" "cluster_firewall" {
  enabled = true

  ebtables      = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"

  log_ratelimit {
    enabled = false
  }
}

# Only allow SSH from the LAN.
resource "proxmox_virtual_environment_cluster_firewall_security_group" "ssh-server" {
  name    = "ssh-server"
  comment = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    macro   = "SSH"
    source  = proxmox_virtual_environment_firewall_alias.lan_network.name
    comment = "Allow SSH from LAN"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "DROP"
    macro   = "SSH"
    comment = "Drop SSH"
    log     = "nolog"
  }
}
