terraform {
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "game-cmangos/terraform.tfstate"

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
      version = "0.77.1"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }

  required_version = ">= 1.11"
}
