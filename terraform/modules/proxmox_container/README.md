# Proxmox LXC Module

Terraform module to create reproducible Debian 12 LXC containers on Proxmox with preset sizes.

## Usage

```hcl
module "lxc" {
  source = "./modules/lxc"

  size            = "medium"
  lxc_name        = "my-app"
  node_name       = "pve1"
  ipv4_address    = "192.168.10.50/24"
  ipv4_gateway    = "192.168.10.1"
  ansible_pass    = var.ansible_pass
  ansible_public_key = var.ansible_public_key

  mount_points = [
    {
      volume = "local-lvm"
      size   = "20G"
      path   = "/mnt/data"
    }
  ]
}
```

## Available Sizes

**Standard**
- `nano`   → 1 vCPU, 1 GB RAM
- `small`  → 1 vCPU, 2 GB RAM
- `medium` → 2 vCPU, 4 GB RAM
- `large`  → 4 vCPU, 8 GB RAM
- `xlarge` → 6 vCPU, 16 GB RAM

**High Memory**
- `highmem-medium` → 2 vCPU, 24 GB RAM
- `highmem-large`  → 4 vCPU, 48 GB RAM

**High CPU (Compute)**
- `compute-large`  → 8 vCPU, 16 GB RAM
- `compute-xlarge` → 16 vCPU, 32 GB RAM

## Variables

| Name                | Type     | Default     | Description |
|---------------------|----------|-------------|-----------|
| `node_name`         | string   | -           | Proxmox node name |
| `lxc_name`          | string   | -           | Hostname of the LXC |
| `size`              | string   | `"small"`   | Preset size (see list above) |
| `mount_points`      | list     | `[]`        | Additional volume mounts |
| `ipv4_address`      | string   | `"dhcp"`    | IPv4 address with CIDR or `"dhcp"` |
| `ipv4_gateway`      | string   | `""`        | IPv4 gateway (required for static IP) |
| `ansible_pass`      | string   | -           | Root password (sensitive) |
| `ansible_public_key`| string   | -           | SSH public key for root |


**Mount point example:**

```hcl
mount_points = [
  { volume = "local-lvm",      size = "10G", path = "/mnt/volume" },
  { volume = "local-lvm:subvol-xxx", size = "50G", path = "/mnt/data" }
]
```

Root disk is fixed at **8 GB** (OS + logs only). Apps should use `mount_points`.

## Requirements

- Proxmox provider `bpg/proxmox` ≥ 0.77.1