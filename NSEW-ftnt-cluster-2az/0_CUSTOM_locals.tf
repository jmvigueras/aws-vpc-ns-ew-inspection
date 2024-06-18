#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "nsew-ftnt"

  tags = {
    Project = "Fortigate VPC N-S inspection"
  }

  volume_tags = {
    Project = "Fortigate instance"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] //Select 2 AZs to deploy

  # VPC - CIDR
  fgt_vpc_cidr = "10.1.0.0/24"

  # AWS cidrs ranges
  aws_cidrs = "10.0.0.0/8"

  # TGW id (provide TGW id to update route tables)
  # (if "" doesn't create route tables)
  tgw_id = ""

  # CIDR used to limit access to Fortigate Management Interface
  admin_cidrs = ["10.0.0.0/8"]

  #-----------------------------------------------------------------------------------------------------
  # FMG and FAZ (optional)
  #-----------------------------------------------------------------------------------------------------
  # Configure FAZ and FMG IPs (optional)
  faz_ip = "" // Update with FAZ IP, if deployed in this code: module.faz.private_ip or public_ip
  fmg_ip = "" // Update with FMG IP, if deployed in this code: module.fmg.private_ip or public_ip
}
