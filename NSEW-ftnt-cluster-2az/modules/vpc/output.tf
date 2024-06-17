output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.vpc.arn
}

output "subnets" {
  description = "Description of the subnets"
  value       = local.o_subnets
}

output "subnet_list" {
  description = "List of subnets"
  value       = local.o_subnet_list
}

output "subnet_cidrs" {
  description = "CIDRs of the subnets"
  value       = local.o_subnet_cidrs
}

output "subnet_ids" {
  description = "List of subnets ID"
  value       = local.o_subnet_ids
}

output "subnet_arns" {
  description = "List of subnets ARNs"
  value       = local.o_subnet_arns
}

output "subnet_public_cidrs" {
  description = "CIDRs of public subnets"
  value       = local.o_subnet_public_cidrs
}

output "subnet_public_ids" {
  description = "IDs of public subnets"
  value       = local.o_subnet_public_ids
}

output "subnet_private_cidrs" {
  description = "CIDRs of private subnets"
  value       = local.o_subnet_private_cidrs
}

output "subnet_private_ids" {
  description = "IDs of private subnets"
  value       = local.o_subnet_private_ids
}

output "rt_public_ids" {
  description = "IDs of public route tables"
  value       = local.o_rt_public_ids
}

output "rt_private_ids" {
  description = "IDs of private route tables"
  value       = local.o_rt_private_ids
}

output "rt_ids" {
  description = "IDs of all route tables"
  value       = local.o_rt_ids
}

output "sg_ids" {
  description = "IDs of security groups"
  value = {
    allow_all = aws_security_group.sg_allow_all_admin_cidrs.id
  }
}
