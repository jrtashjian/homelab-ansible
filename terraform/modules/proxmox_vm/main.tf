terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.41.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "base_vm" {
  node_name = var.node_name
  name      = var.vm_name
  tags      = ["terraform"]

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
    cores = var.cpu
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "machines"
    size         = var.disk_size
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

data "proxmox_virtual_environment_vms" "all_vms" {
  node_name = var.node_name
}

locals {
  cloudinit_vm = try(
    [for vm in data.proxmox_virtual_environment_vms.all_vms.vms : vm if vm.name == var.cloudinit_template][0],
    null
  )
}
