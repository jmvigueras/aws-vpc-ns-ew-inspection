locals {
  #-----------------------------------------------------------------------------------------------------
  # Other variables
  #-----------------------------------------------------------------------------------------------------
  admin_port    = "8443"
  instance_type = "c6i.2xlarge"
  fgt_build     = "build1639" #7.2.8
  license_type  = "byol"

  fgt_number_peer_az = 1
  fgt_cluster_type   = "fgcp" // choose type of cluster either fgsp or fgcp  

  # List of public and private subnets based on fgt_subnet_tags
  public_subnet_names = [
    local.fgt_subnet_tags["port1.${local.subnet_tags["public"]}"]
  ]
  private_subnet_names = [
    local.fgt_subnet_tags["port2.${local.subnet_tags["private"]}"],
    local.fgt_subnet_tags["port3.${local.subnet_tags["mgmt"]}"],
    "tgw"
  ]

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - leave blank or don't add elements to not create a ports
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  fgt_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "public"
    "port2.${local.subnet_tags["private"]}" = "private"
    "port3.${local.subnet_tags["mgmt"]}"    = "mgmt"
  }

  # fgt_tags -> map tags used in fgt_subnet_tags to tag subnet names (this valued are define in modules as default)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha"
  }
}