provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true
}

resource "proxmox_virtual_environment_firewall_alias" "lan_network" {
  name    = "LAN"
  cidr    = "192.168.10.0/24"
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
