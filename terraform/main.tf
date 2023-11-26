terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.10.12:8006/"
  insecure = true
}

data "proxmox_virtual_environment_vms" "all_vms" {}

locals {
  cloudinit_vm = try(
    [for vm in data.proxmox_virtual_environment_vms.all_vms.vms : vm if vm.name == "cloudinit-debian-12"][0],
    null
  )
}

resource "proxmox_virtual_environment_vm" "docker" {
  count = 1

  node_name = "pve-node02"

  name = format("docker%02d", count.index + 1)
  tags = ["terraform"]

  clone {
    vm_id   = local.cloudinit_vm.vm_id
    retries = 3
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    type  = "x86-64-v2-AES"
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "machines"
    size         = 8
    interface    = "scsi0"
    discard      = "on"
    iothread     = true
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  network_device {
    firewall = true
  }

  vga {
    type = "serial0"
  }

  serial_device {}

  initialization {
    datastore_id = "machines"

    user_account {
      username = var.ANSIBLE_USER
      password = var.ANSIBLE_PASS
      keys     = [var.ANSIBLE_PUBLIC_KEY]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

# Add the VMs to the Ansible inventory.
resource "ansible_host" "docker" {
  for_each = { for instance in proxmox_virtual_environment_vm.docker : instance.name => instance }

  name   = each.key
  groups = ["docker"]

  variables = {
    # lo is the first interface, eth0 is the second.
    ansible_host = each.value.ipv4_addresses[1][0]
  }
}

locals {
  minecraft_lxc = {
    "proxy" = {
      cores       = 2
      memory      = 2048
      mac_address = "7e:a2:d8:e0:b4:18"
      groups      = ["minecraft", "minecraft-proxies"]
    }
    "lobby" = {
      cores       = 2
      memory      = 2048
      mac_address = "9a:77:71:bc:a0:7d"
      groups      = ["minecraft", "minecraft-worlds"]
    }
    "main" = {
      cores       = 8
      memory      = 8192
      mac_address = "3e:2c:e3:97:c8:25"
      groups      = ["minecraft", "minecraft-worlds"]
    }
    "hardcore" = {
      cores       = 8
      memory      = 8192
      mac_address = "6e:00:94:63:d3:0a"
      groups      = ["minecraft", "minecraft-worlds"]
    }
  }
}

resource "proxmox_virtual_environment_container" "minecraft" {
  for_each = local.minecraft_lxc

  node_name = "pve-node02"

  tags = ["terraform"]

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "machines"
    size         = 10
  }

  network_interface {
    name        = "eth0"
    firewall    = true
    mac_address = each.value.mac_address
  }

  initialization {
    hostname = "minecraft-${each.key}"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      password = var.ANSIBLE_PASS
      keys     = [var.ANSIBLE_PUBLIC_KEY]
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
}

resource "proxmox_virtual_environment_file" "debian_container_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve-node02"

  source_file {
    path = "http://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst"
  }
}

# Add the LXCs to the Ansible inventory.
resource "ansible_host" "minecraft" {
  for_each = proxmox_virtual_environment_container.minecraft

  name   = each.value.initialization[0].hostname
  groups = local.minecraft_lxc[each.key].groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host     = each.value.initialization[0].hostname
  }
}
