#------------------------------------------------------------------------------
# Create VPC
#------------------------------------------------------------------------------
module "mgmt_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.6"

  prefix     = "${local.prefix}-mgmt"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.mgmt_vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}
#------------------------------------------------------------------------------
# Create FMG and FAZ:
# - FMG
# - FAZ
#------------------------------------------------------------------------------
module "fmg" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/faz"
  version = "0.0.6"

  prefix         = local.prefix
  keypair        = trimspace(aws_key_pair.keypair.key_name)
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id       = module.mgmt_vpc.subnet_ids["az1"][local.fmg_faz_subnet_name]
  subnet_cidr     = module.mgmt_vpc.subnet_cidrs["az1"][local.fmg_faz_subnet_name]
  security_groups = [module.mgmt_vpc.sg_ids["default"]]
  cidr_host       = 10

  config_eip = true

  license_type = "byol"
}
module "faz" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/faz"
  version = "0.0.6"

  prefix         = local.prefix
  keypair        = trimspace(aws_key_pair.keypair.key_name)
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id       = module.mgmt_vpc.subnet_ids["az1"][local.fmg_faz_subnet_name]
  subnet_cidr     = module.mgmt_vpc.subnet_cidrs["az1"][local.fmg_faz_subnet_name]
  security_groups = [module.mgmt_vpc.sg_ids["default"]]
  cidr_host       = 11

  config_eip = true

  license_type = "byol"
}
#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Update private route table asigned to Management subnet
module "mgmt_vpc_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.7"

  count = local.tgw_id != "" ? 1 : 0

  tgw_id     = local.tgw_id
  tgw_rt_ids = local.mgmt_rt_ids

  destination_cidr_block = local.aws_cidrs
}
locals {
  mgmt_rt_subnet_names = [local.fmg_faz_subnet_name]
  # Create map of RT IDs where add routes pointing to a TGW ID
  mgmt_rt_ids = {
    for pair in setproduct(local.mgmt_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.mgmt_vpc.rt_ids[pair[1]][pair[0]]
  }
}



#------------------------------------------------------------------------------
# General resources
#------------------------------------------------------------------------------
# Create key-pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "keypair" {
  key_name   = "${local.prefix}-eu-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}