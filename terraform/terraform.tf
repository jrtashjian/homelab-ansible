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

  required_version = ">= 1.6"
}
