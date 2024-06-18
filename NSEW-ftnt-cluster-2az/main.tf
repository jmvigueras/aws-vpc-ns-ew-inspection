#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instances
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "fgt_vpc" {
  source = "./modules/vpc"

  prefix      = local.prefix
  admin_cidrs = local.admin_cidrs
  region      = local.region
  azs         = local.azs

  cidr = local.fgt_vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}
# Create EIPs for NAT GWs
resource "aws_eip" "nat_gw_eip" {
  for_each = { for i, v in local.azs :
    "az${i + 1}" => local.fgt_subnet_tags["port1.${local.subnet_tags["public"]}"]
  }

  domain = "vpc"

  tags = merge(
    local.tags,
    { Name = "${local.prefix}-natgw-${each.key}" }
  )
}
# Create NAT GW in each AZ in FGT subnet public
resource "aws_nat_gateway" "nat_gw" {
  depends_on = [module.fgt_nis]

  for_each = { for i, v in local.azs :
    "az${i + 1}" => local.fgt_subnet_tags["port1.${local.subnet_tags["public"]}"]
  }

  allocation_id = aws_eip.nat_gw_eip[each.key].id
  subnet_id     = module.fgt_vpc.subnet_ids[each.key][each.value]

  tags = merge(
    local.tags,
    { Name = "${local.prefix}-natgw-${each.key}" }
  )
}
# Create FGT NIs
module "fgt_nis" {
  source = "./modules/fgt_ni_sg"

  prefix = local.prefix
  azs    = local.azs

  vpc_id      = module.fgt_vpc.vpc_id
  subnet_list = module.fgt_vpc.subnet_list

  subnet_tags     = local.subnet_tags
  fgt_subnet_tags = local.fgt_subnet_tags

  fgt_number_peer_az = local.fgt_number_peer_az
  cluster_type       = local.fgt_cluster_type

  config_eip_to_mgmt = false
  sg_public_cidrs    = local.admin_cidrs //CDIRS to configure SG inbound rules Public interface (default: "0.0.0.0/0")
  admin_cidrs        = local.admin_cidrs //CDIRS to configure SG inbound rules Management interface (default: rfc1918 cidrs)
}
# Create FGTs config
module "fgt_config" {
  source = "./modules/fgt_config"

  for_each = { for k, v in module.fgt_nis.fgt_ports_config : k => v }

  admin_cidr     = element(local.admin_cidrs, 0)
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
  source = "./modules/fgt"

  prefix        = local.prefix
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.fgt_config : k => v.fgt_config }

  tags        = local.tags
  volume_tags = local.volume_tags
}
#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Create TGW endpoint subnet RT 0.0.0.0/0 to point to Fortigate private NI
module "subnet_routes_to_fgt_ni" {
  source = "./modules/vpc_routes"

  ni_id     = module.fgt_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = { for i, v in local.azs : "az${i + 1}-tgw" => module.fgt_vpc.rt_ids["az${i + 1}"]["tgw"] }
}
# Create Fortigate MGMT subnet RT 0.0.0.0/0 to point to NAT Gateway
module "subnet_routes_to_natgw" {
  source = "./modules/vpc_routes"

  for_each = { for i, v in local.azs :
    "az${i + 1}" => local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"]
  }

  natgw_id     = aws_nat_gateway.nat_gw[each.key].id
  natgw_rt_ids = { "${each.value}-${each.key}" = module.fgt_vpc.rt_ids[each.key][each.value] }
}
# Create Fortigate MGMT subnet RT "local.aws_cidr" to point to TGW (if local.tgw_id is configured)
module "subnet_routes_to_tgw_mgmt" {
  source = "./modules/vpc_routes"

  tgw_id = local.tgw_id
  tgw_rt_ids = { for i, v in local.azs :
    "az${i + 1}-${local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"]}" =>
    module.fgt_vpc.rt_ids["az${i + 1}"][local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"]] if local.tgw_id != ""
  }

  destination_cidr_block = local.aws_cidrs
}
# Create Fortigate private subnet RT 0.0.0.0/0 to point to TGW (if local.tgw_id is configured)
module "subnet_routes_to_tgw_private" {
  source = "./modules/vpc_routes"

  tgw_id = local.tgw_id
  tgw_rt_ids = { for i, v in local.azs :
    "az${i + 1}-${local.fgt_subnet_tags["port2.${local.subnet_tags["private"]}"]}" =>
    module.fgt_vpc.rt_ids["az${i + 1}"][local.fgt_subnet_tags["port2.${local.subnet_tags["private"]}"]] if local.tgw_id != ""
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