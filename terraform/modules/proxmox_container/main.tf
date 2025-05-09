terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

resource "proxmox_virtual_environment_container" "base_lxc" {
  node_name = var.node_name
  pool_id   = var.pool_id
  tags      = ["terraform"]

  cpu {
    cores = var.cpu
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "machines"
    size         = var.disk_size
  }

  network_interface {
    name     = "eth0"
    firewall = true
  }

  initialization {
    hostname = var.lxc_name

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    user_account {
      password = var.ansible_pass
      keys     = [var.ansible_public_key]
    }
  }

  features {
    nesting = true
  }

  unprivileged = true

  operating_system {
    type             = "debian"
    template_file_id = proxmox_virtual_environment_file.debian_container_template.id
  }

  depends_on = [proxmox_virtual_environment_file.debian_container_template]

  lifecycle {
    ignore_changes = [description]
  }
}

resource "proxmox_virtual_environment_file" "debian_container_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.node_name

  source_file {
    path = "http://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst"
  }
}
