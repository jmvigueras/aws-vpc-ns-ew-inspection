#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "mngmt-fgt"

  tags = {
    Project = "Management VPC Fortigate"
  }

  # Region and AZ to deploy VPC
  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] //Select 2 AZs to deploy

  # VPC - CIDR
  mgmt_vpc_cidr = "10.3.0.0/24"

  # AWS cidrs ranges
  aws_cidrs = "10.0.0.0/8"

  # TGW id (provide TGW id to update route tables)
  # (if "" doesn't create route tables)
  tgw_id = ""

  #-----------------------------------------------------------------------------------------------------
  # Other variables
  #-----------------------------------------------------------------------------------------------------
  # Admin CIDR
  admin_cidr = "0.0.0.0/0"

  # Subnet FMG and FAZ name
  fmg_faz_subnet_name = "mgmt"

  # List of public and private subnets
  public_subnet_names  = [local.fmg_faz_subnet_name]
  private_subnet_names = ["tgw"]
}
