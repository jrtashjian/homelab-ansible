terraform {
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "game-minecraft/terraform.tfstate"

    endpoints = {
      s3 = "http://192.168.10.11:9000"
    }

    insecure       = true
    use_path_style = true

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.43.3"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }

  required_version = ">= 1.6"
}
