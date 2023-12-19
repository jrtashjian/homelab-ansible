variable "node02_user" {
  description = "pve-node02 user"
  type        = string
}

variable "node02_pass" {
  description = "pve-node02 password"
  type        = string
  sensitive   = true
}

variable "node03_user" {
  description = "pve-node03 user"
  type        = string
}

variable "node03_pass" {
  description = "pve-node03 password"
  type        = string
  sensitive   = true
}

variable "int_jrtashjian_com_cert" {
  description = "int.jrtashjian.com certificate"
  type        = string
  sensitive   = true
}

variable "int_jrtashjian_com_key" {
  description = "int.jrtashjian.com private key"
  type        = string
  sensitive   = true
}
