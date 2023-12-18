output "name" {
  description = "List of names of the LXC created by the module."
  value       = join(",", proxmox_virtual_environment_container.base_lxc[*].initialization[0].hostname)
}

output "ipv4_address" {
  description = "List of IPv4 addresses of the LXC created by the module."
  value       = tolist(proxmox_virtual_environment_container.base_lxc[*].initialization[0].ip_config[0].ipv4[0].address)[0]
}

output "id" {
  description = "List of IDs of the LXC created by the module."
  value       = tolist(proxmox_virtual_environment_container.base_lxc[*].id)[0]
}

output "node_name" {
  description = "List of node names of the LXC created by the module."
  value       = tolist(proxmox_virtual_environment_container.base_lxc[*].node_name)[0]
}