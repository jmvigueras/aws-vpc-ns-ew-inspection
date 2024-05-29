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

  config_fmg = local.fmg_ip != "" ? true : false
  fmg_ip     = local.fmg_ip

  config_faz = local.faz_ip != "" ? true : false
  faz_ip     = local.faz_ip

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
# Update VPC routes
#------------------------------------------------------------------------------
# Create TGW endpoint subnet RT 0.0.0.0/0 to point to Fortigate private NI
module "ns_tgw_vpc_routes_to_fgt_ni" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.7"

  ni_id     = module.fgt_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.ns_ni_rt_ids
}
# Create Fortigate public subnet RT "local.aws_cidr" to point to TGW
module "ns_fgt_public_routes_to_tgw" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.7"

  count = local.tgw_id != "" ? 1 : 0

  tgw_id     = local.tgw_id
  tgw_rt_ids = local.ns_tgw_rt_ids_public

  destination_cidr_block = local.aws_cidrs
}
# Create Fortigate private subnet RT 0.0.0.0/0 to point to TGW
module "ns_fgt_private_routes_to_tgw" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.7"

  count = local.tgw_id != "" ? 1 : 0

  tgw_id     = local.tgw_id
  tgw_rt_ids = local.ns_tgw_rt_ids_private
}

# Variables to create maps of route tables to create subnet routes
locals {
  ns_ni_rt_subnet_names    = ["tgw"]
  ns_tgw_rt_subnet_private = ["private"]
  ns_tgw_rt_subnet_public  = ["mgmt"]
  # Create map of RT IDs where add routes pointing to a FGT NI
  ns_ni_rt_ids = {
    for pair in setproduct(local.ns_ni_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  ns_tgw_rt_ids_private = {
    for pair in setproduct(local.ns_tgw_rt_subnet_private, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  ns_tgw_rt_ids_public = {
    for pair in setproduct(local.ns_tgw_rt_subnet_public, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.fgt_vpc.rt_ids[pair[1]][pair[0]]
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
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}