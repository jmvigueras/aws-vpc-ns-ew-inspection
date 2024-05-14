# Output
output "lb_target_group_arn" {
  description = "ARN of the LB Target Group"
  value       = aws_lb_target_group.gwlb_target_group.arn
}
output "lb_target_group_id" {
  description = "ID of the LB Target Group"
  value       = aws_lb_target_group.gwlb_target_group.id
}
output "gwlbe_ips" {
  description = "List of GWLB Endpoint private IPs"
  value       = { for k, v in data.aws_network_interface.gwlb_ni : k => v.private_ip }
}
output "gwlbe_ids" {
  description = "List of GWLB Endpoint Network Interface IDs"
  value       = { for k, v in data.aws_network_interface.gwlb_ni : k => v.id }
}
output "gwlb_service_name" {
  description = "Service name of the GWLB VPC endpoint"
  value       = aws_vpc_endpoint_service.gwlb_service.service_name
}