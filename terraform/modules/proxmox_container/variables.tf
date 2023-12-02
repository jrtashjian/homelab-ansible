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
}

variable "ANSIBLE_PASS" {
  description = "Ansible password"
  type        = string
  sensitive   = true
}

variable "ANSIBLE_PUBLIC_KEY" {
  description = "Ansible public key"
  type        = string
}