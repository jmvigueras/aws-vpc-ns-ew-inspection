output "fgt_ni_list" {
  description = "List of FortiGate network interfaces"
  value       = local.o_fgt_ni_list
}

output "fgt_ips_map" {
  description = "Map of FortiGate network interfaces IPs"
  value       = local.o_fgt_ips_map
}

output "fgt_ids_map" {
  description = "Map of FortiGate network interfaces IDs"
  value       = local.o_fgt_ids_map
}

output "fgt_eips_map" {
  description = "Map of FortiGate Elastic IPs"
  value       = local.o_fgt_eips_map
}

output "fgt_ports_config" {
  description = "List of FortiGate ports configuration details"
  value       = local.o_fgt_ports_config
}

#-------------------------------
# Debugging 
#-------------------------------
output "ni_list" {
  value = local.ni_list
}