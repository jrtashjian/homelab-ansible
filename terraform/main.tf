terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.10.12:8006/api2/json"
}

resource "proxmox_vm_qemu" "docker" {
  count = 4

  name        = format("docker%02d", count.index + 1)
  target_node = "pve-node02"

  clone   = "cloudinit-debian-12"
  os_type = "cloud-init"
  agent   = 1

  qemu_os   = "l26"
  cpu       = "x86-64-v2-AES"
  scsihw    = "virtio-scsi-single"
  boot      = "order=scsi0"
  ipconfig0 = "ip=dhcp"

  cores  = 2
  memory = 2048

  ciuser     = var.ANSIBLE_USER
  cipassword = var.ANSIBLE_PASS
  sshkeys    = var.ANSIBLE_PUBLIC_KEY

  vga {
    type = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
  }

  disk {
    type     = "scsi"
    storage  = "machines"
    size     = "10G"
    discard  = "on"
    iothread = 1
  }
}

# Add the VMs to the Ansible inventory.
resource "ansible_host" "docker" {
  count = 4

  name   = proxmox_vm_qemu.docker[count.index].name
  groups = ["docker"]

  variables = {
    ansible_host = proxmox_vm_qemu.docker[count.index].ssh_host
  }
}
