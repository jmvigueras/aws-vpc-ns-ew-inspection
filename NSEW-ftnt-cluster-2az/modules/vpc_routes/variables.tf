variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = null
}

variable "admin_cidr" {
  description = "Created for future use"
  type        = string
  default     = "0.0.0.0/0"
}

variable "destination_cidr_block" {
  description = "Default destination block of created new routes"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tgw_rt_ids" {
  description = "List of Route Tables ID to add private routes to a TGW"
  type        = map(string)
  default     = {}
}

variable "ni_rt_ids" {
  description = "List of Route Tables ID to add private routes to a Network Interface"
  type        = map(string)
  default     = {}
}

variable "gwlb_rt_ids" {
  description = "List of Route Tables ID to add private routes to a GWLB Endpoint"
  type        = map(string)
  default     = {}
}

variable "core_network_rt_ids" {
  description = "List of Route Tables ID to add private routes to a Core Network Endpoint"
  type        = map(string)
  default     = {}
}

variable "natgw_rt_ids" {
  description = "List of Route Tables ID to add private routes to a NAT Gateway"
  type        = map(string)
  default     = {}
}

variable "ni_id" {
  description = "AWS instance NI ID to use in routes"
  type        = string
  default     = null
}

variable "tgw_id" {
  description = "AWS TGW ID to use in routes"
  type        = string
  default     = null
}

variable "gwlbe_id" {
  description = "AWS GWLB endpoint ID to use in routes"
  type        = string
  default     = null
}

variable "core_network_arn" {
  description = "AWS Core Network ARN to use in routes"
  type        = string
  default     = null
}

variable "natgw_id" {
  description = "NAT Gateway ID to use in routes"
  type        = string
  default     = null
}