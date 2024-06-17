output "fgt_list" {
  description = "List of FortiGate details"
  value       = local.o_fgt_list
}

output "fgt_peer_az_ids" {
  description = "IDs of FortiGate instances in each Availability Zone"
  value       = local.o_fgt_peer_az_ids
}