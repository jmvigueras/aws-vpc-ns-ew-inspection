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

variable "volume_tags" {
  description = "Tags for instance volumenes"
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

variable "fgt_ni_list" {
  description = "List of FortiGate details with NI IDs"
  type        = map(any)
  default     = {}
}

variable "fgt_config" {
  description = "Map of string peer each FGT instance user-data"
  type        = map(string)
  default     = {}
}

variable "keypair" {
  description = "Provide the name of the keypair to use"
  type        = string
  default     = "null"
}

variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  type        = string
  default     = "c6i.large"
}

variable "license_type" {
  description = "License type to create Fortigate instnace, either byol or payg"
  type        = string
  default     = "payg"
}

variable "fgt_build" {
  description = "Fortigate VM version (default build1575 -> FortiOS 7.2.6)"
  type        = string
  default     = "build1577"
}