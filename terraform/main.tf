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

locals {
  minecraft_lxc = {
    "proxy" = {
      cores  = 2
      memory = 2048
      hwaddr = "7e:a2:d8:e0:b4:18"
      groups = [ "minecraft", "minecraft-proxies" ]
    }
    "lobby" = {
      cores  = 2
      memory = 2048
      hwaddr = "9a:77:71:bc:a0:7d"
      groups = [ "minecraft", "minecraft-worlds" ]
    }
    "main" = {
      cores  = 8
      memory = 8192
      hwaddr = "3e:2c:e3:97:c8:25"
      groups = [ "minecraft", "minecraft-worlds" ]
    }
    "hardcore" = {
      cores  = 8
      memory = 8192
      hwaddr = "6e:00:94:63:d3:0a"
      groups = [ "minecraft", "minecraft-worlds" ]
    }
  }
}

resource "proxmox_lxc" "minecraft" {
  for_each = local.minecraft_lxc

  hostname    = "minecraft-${each.key}"
  target_node = "pve-node02"

  ostemplate = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"

  cores  = each.value.cores
  memory = each.value.memory

  password        = var.ANSIBLE_PASS
  ssh_public_keys = var.ANSIBLE_PUBLIC_KEY

  onboot       = true
  start        = true
  unprivileged = true

  features {
    nesting = true
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = "dhcp"
    hwaddr   = each.value.hwaddr
  }

  rootfs {
    storage = "machines"
    size    = "10G"
  }
}

# Add the LXCs to the Ansible inventory.
resource "ansible_host" "minecraft" {
  for_each = local.minecraft_lxc

  name   = proxmox_lxc.minecraft[each.key].hostname
  groups = each.value.groups

  variables = {
    ansible_ssh_user = "root"
    ansible_host = proxmox_lxc.minecraft[each.key].hostname
  }
}
