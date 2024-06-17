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

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = null
}

variable "azs" {
  description = "Availability zones where Fortigates will be deployed"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1c"]
}

variable "admin_cidrs" {
  description = "List of CIDRs for the administrative access to Fortigates"
  type        = list(string)
  default     = ["192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"]
}

variable "sg_public_cidrs" {
  description = "List of CIDRs for public access to Fortigates"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "sg_private_cidrs" {
  description = "List of CIDRs for the private access to Fortigates"
  type        = list(string)
  default     = ["192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"]
}

variable "admin_port" {
  description = "Port for the administrative access to Fortigates"
  type        = string
  default     = "8443"
}

variable "vpc_id" {
  description = "VPC ID where Fortigates will be deployed"
  type        = string
  default     = null
}

variable "subnet_tags" {
  description = "Tag used to define each type of subnet, needed: public, private, mgmt and ha"
  type        = map(string)
  default = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }
}

variable "fgt_subnet_tags" {
  description = "Subnet tags map assigned to each subnet, must much with variable subnet_tags"
  type        = map(string)
  default = {
    "port0.public"  = "subnet-public"
    "port1.private" = "subnet-private"
    "port2.mgmt"    = "subnet-mgmt"
  }
}

variable "config_eip_to_mgmt" {
  description = "Enable EIP to MGMT interface if true"
  type        = bool
  default     = true
}

variable "cluster_type" {
  description = "Type of cluster Fortigates will use, either fgcp or fgsp"
  type        = string
  default     = ""
}

variable "subnet_list" {
  description = "List of subnets where Fortigates will be deployed"
  type        = list(map(string))
  default     = [{}]
}

variable "cidr_host" {
  description = "First IP number of the network to assign"
  type        = number
  default     = 10
}

variable "fgt_number_peer_az" {
  description = "Number of Fortigates in each AZ"
  type        = number
  default     = 1
}