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

variable "tags" {
  description = "The tags to apply to the VM"
  type        = list(string)
  default     = []
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

variable "ANSIBLE_USER" {
  description = "Ansible user"
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