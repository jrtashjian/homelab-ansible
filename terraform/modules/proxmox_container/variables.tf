variable "node_name" {
  description = "The name of the node to create the LXC on"
  type        = string
}

variable "lxc_name" {
  description = "The name of the LXC to create"
  type        = string
}

variable "size" {
  description = "The size of the LXC (nano, small, medium, large, xlarge, highmem-medium, highmem-large, compute-large, compute-xlarge)"
  type        = string
  default     = "small"

  validation {
    condition = contains(["nano", "small", "medium", "large", "xlarge", "highmem-medium", "highmem-large", "compute-large", "compute-xlarge"], var.size)
    error_message = "Size must be one of: nano, small, medium, large, xlarge, highmem-medium, highmem-large, compute-large, compute-xlarge"
  }
}

variable "disk_size" {
  description = "The size of the disk in GB"
  type        = number
  default     = 8
}

variable "ipv4_address" {
  description = "The IPv4 address to assign to the LXC"
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "The IPv4 gateway to assign to the LXC"
  type        = string
  default     = ""
}

variable "pool_id" {
  description = "The ID of the pool to add the LXC to"
  type        = string
  default     = ""
}

variable "ansible_pass" {
  description = "Ansible password"
  type        = string
  sensitive   = true
}

variable "ansible_public_key" {
  description = "Ansible public key"
  type        = string
}
