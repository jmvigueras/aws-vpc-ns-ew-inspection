variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "terraform"
}

variable "tags" {
  description = "Tags for created resources"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs that NLB will use"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where targets are deployed"
  type        = string
}

variable "fgt_ips" {
  description = "List of IPs of Fortigates used as NLB target groups"
  type        = list(string)
  default     = []
}

variable "backend_port" {
  description = "Fortigates backend port used for health checks probes"
  type        = string
  default     = "8008"
}

variable "backend_protocol" {
  description = "Fortigates backend protocol used for health checks probes"
  type        = string
  default     = "HTTP"
}

variable "backend_interval" {
  description = "Health checks probes interval in seconds"
  type        = number
  default     = 10
}

variable "slow_start" {
  description = "Amount time for targets to warm up before the load balancer sends them a full share of requests"
  type        = number
  default     = 60
}

variable "deregistration_delay" {
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 60
}

variable "target_failover" {
  description = "Indicates how the GWLB handles existing flows when a target is deregistered or unhealthy, either rebalance or no_rebalance"
  type        = string
  default     = "rebalance"
}