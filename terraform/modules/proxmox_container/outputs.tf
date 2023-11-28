output "name" {
  description = "List of LXC names created by the module."
  value       = join(",", proxmox_virtual_environment_container.base_lxc[*].initialization[0].hostname)
}

output "ipv4_address" {
  description = "List of VM names created by the module."
  value       = proxmox_virtual_environment_container.base_lxc[*].initialization[0].ip_config[0].ipv4[0].address
}
