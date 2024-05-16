#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "ew-fgt"

  tags = {
    Project = "Fortigate VPC E-W inspection"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] //Select AZs to deploy

  # VPC - CIDR
  fgt_vpc_cidr = "10.2.0.0/24"

  # AWS cidrs ranges
  aws_cidrs = "10.0.0.0/8"

  # TGW id (provide TGW id to update route tables)
  # (if "" doesn't create route tables)
  tgw_id = ""

  #-----------------------------------------------------------------------------------------------------
  # FMG and FAZ
  #-----------------------------------------------------------------------------------------------------
  faz_ip = "" // Update with FAZ IP (optional)
  fmg_ip = "" // Update with FMG IP (optional)

  #-----------------------------------------------------------------------------------------------------
  # Others variables
  #-----------------------------------------------------------------------------------------------------
  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"
  //admin_cidr = "" #(customize to your public range if desired)
  instance_type = "c6i.xlarge"
  fgt_build     = "build1639" #7.2.8
  license_type  = "byol"

  fgt_number_peer_az = 1
  fgt_cluster_type   = "fgsp" // choose type of cluster either fgsp or fgcp  

  # VPC - list of public and private subnet names
  public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port3.mgmt"]]
  private_subnet_names = [local.fgt_subnet_tags["port2.private"], local.fgt_subnet_tags["port4.ha-sync"], "tgw", "gwlb"]

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - leave blank or don't add elements to not create a ports
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  fgt_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "public"
    "port2.${local.subnet_tags["private"]}" = "private"
    "port3.${local.subnet_tags["mgmt"]}"    = ""
    "port4.${local.subnet_tags["ha"]}"      = ""
  }

  # fgt_tags -> map tags used in fgt_subnet_tags to tag subnet names (this valued are define in modules as default)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }
}
