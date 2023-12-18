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