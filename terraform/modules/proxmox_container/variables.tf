variable "node_name" {
  description = "The name of the node to create the LXC on"
  type        = string
}

variable "lxc_name" {
  description = "The name of the LXC to create"
  type        = string
}

variable "cpu" {
  description = "The CPU configuration for the LXC"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The memory configuration for the LXC"
  type        = number
  default     = 2048
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
