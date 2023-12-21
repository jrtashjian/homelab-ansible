provider "proxmox" {
  endpoint = "https://pve-node02.int.jrtashjian.com:8006/"
  insecure = true

  ssh {
    agent    = true
    username = var.node02_user
    password = var.node02_pass
  }
}

provider "proxmox" {
  alias    = "node03"
  endpoint = "https://pve-node03.int.jrtashjian.com:8006/"
  insecure = true

  ssh {
    agent    = true
    username = var.node03_user
    password = var.node03_pass
  }
}

# Upload wildcard certificate and private key.
resource "proxmox_virtual_environment_certificate" "pve_node02_int_jrtashjian_com" {
  certificate = trimspace(var.int_jrtashjian_com_cert)
  node_name   = "pve-node02"
  private_key = trimspace(var.int_jrtashjian_com_key)
}
resource "proxmox_virtual_environment_certificate" "pve_node03_int_jrtashjian_com" {
  certificate = trimspace(var.int_jrtashjian_com_cert)
  node_name   = "pve-node03"
  private_key = trimspace(var.int_jrtashjian_com_key)
}

# Add firewall aliases.
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

resource "proxmox_virtual_environment_file" "node02_debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve-node02"

  source_file {
    path      = "http://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    file_name = "debian-12-genericcloud-amd64.img"
  }
}

resource "proxmox_virtual_environment_file" "node03_debian_cloud_image" {
  provider = proxmox.node03

  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve-node03"

  source_file {
    path      = "http://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    file_name = "debian-12-genericcloud-amd64.img"
  }
}

resource "proxmox_virtual_environment_file" "node02_debian_vendor_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve-node02"

  source_raw {
    data = <<EOF
#cloud-config
runcmd:
  - apt update
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

    file_name = "debian-vendor-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "node03_debian_vendor_config" {
  provider = proxmox.node03

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve-node03"

  source_raw {
    data = <<EOF
#cloud-config
runcmd:
  - apt update
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

    file_name = "debian-vendor-config.yaml"
  }
}
