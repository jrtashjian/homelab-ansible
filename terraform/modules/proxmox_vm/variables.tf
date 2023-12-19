variable "node_name" {
  description = "The name of the node to create the VM on"
  type        = string
}

variable "cloudinit_template" {
  description = "The name of the cloudinit template to use"
  type        = string
}

variable "vm_name" {
  description = "The name of the VM to create"
  type        = string
}

variable "cpu" {
  description = "The CPU configuration for the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The memory configuration for the VM"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "The size of the disk in GB"
  type        = number
  default     = 8
}

variable "ansible_user" {
  description = "Ansible user"
  type        = string
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
