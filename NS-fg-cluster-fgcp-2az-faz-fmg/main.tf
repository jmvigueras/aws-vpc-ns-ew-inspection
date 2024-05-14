#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instances
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "fgt_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.6"

  prefix     = "${local.prefix}-ns"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.fgt_vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}
# Create FGT NIs
module "fgt_nis" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_ni_sg"
  version = "0.0.6"

  prefix = "${local.prefix}-ns"
  azs    = local.azs

  vpc_id      = module.fgt_vpc.vpc_id
  subnet_list = module.fgt_vpc.subnet_list

  subnet_tags     = local.subnet_tags
  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type
}
# Create FGTs config
module "fgt_config" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_config"
  version = "0.0.6"

  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.fgt_nis.fgt_ports_config

  config_fmg = true
  fmg_ip     = module.fmg.private_ip

  config_faz = true
  faz_ip     = module.faz.private_ip

  static_route_cidrs = [local.aws_cidrs]
}
# Create FGT for hub EU
module "fgt" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt"
  version = "0.0.6"

  prefix        = "${local.prefix}-ns"
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }
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

  subnet_id       = module.fgt_vpc.subnet_ids["az1"][local.fmg_faz_subnet_name]
  subnet_cidr     = module.fgt_vpc.subnet_cidrs["az1"][local.fmg_faz_subnet_name]
  security_groups = [module.fgt_vpc.sg_ids["default"]]

  cidr_host = 10

  license_type = "byol"
}
module "faz" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/faz"
  version = "0.0.6"

  prefix         = local.prefix
  keypair        = trimspace(aws_key_pair.keypair.key_name)
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_id       = module.fgt_vpc.subnet_ids["az1"][local.fmg_faz_subnet_name]
  subnet_cidr     = module.fgt_vpc.subnet_cidrs["az1"][local.fmg_faz_subnet_name]
  security_groups = [module.fgt_vpc.sg_ids["default"]]

  cidr_host = 11

  license_type = "byol"
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
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 20
  special = false
  numeric = true
}
# Get your public IP
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}