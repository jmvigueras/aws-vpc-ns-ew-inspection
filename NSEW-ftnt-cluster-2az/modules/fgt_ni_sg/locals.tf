locals {
  # ------------------------------------------------------------------------------------
  # Parse inputs
  # ------------------------------------------------------------------------------------
  # Subnet tags prefix
  tag_public  = var.subnet_tags["public"]
  tag_private = var.subnet_tags["private"]
  tag_mgmt    = var.subnet_tags["mgmt"]
  tag_ha      = var.subnet_tags["ha"]

  # FGT subnet list filtered by subnet tags
  public_subnet_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in var.subnet_list :
      subnet if join("-", slice(split("-", subnet["name"]), 0, length(split("-", subnet["name"])) - 1)) == v
    ] if one(slice(split(".", k), 1, 2)) == local.tag_public && v != ""
    ]
  )
  private_subnet_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in var.subnet_list :
      subnet if join("-", slice(split("-", subnet["name"]), 0, length(split("-", subnet["name"])) - 1)) == v
    ] if one(slice(split(".", k), 1, 2)) == local.tag_private && v != ""
    ]
  )
  mgmt_subnet_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in var.subnet_list :
      subnet if join("-", slice(split("-", subnet["name"]), 0, length(split("-", subnet["name"])) - 1)) == v
    ] if one(slice(split(".", k), 1, 2)) == local.tag_mgmt && v != ""
    ]
  )
  ha_subnet_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in var.subnet_list :
      subnet if join("-", slice(split("-", subnet["name"]), 0, length(split("-", subnet["name"])) - 1)) == v
    ] if one(slice(split(".", k), 1, 2)) == local.tag_ha && v != ""
    ]
  )
  # List of AZs
  az_list = [for i, v in var.azs : "az${i + 1}"]
  # List of map with FGT peer AZ
  fgt_peer_az = flatten(
    [for az in local.az_list :
      [for i in range(0, var.fgt_number_peer_az) :
        { "az"  = az
          "fgt" = "fgt${i + 1}"
        }
      ]
    ]
  )
  # Map of AZ
  az_map = { for i, v in var.azs : "az${i + 1}" => v }

  # ------------------------------------------------------------------------------------
  # Create variable list of SGs ids
  # ------------------------------------------------------------------------------------
  # Sanetize inputs var
  sg_public_cidrs  = distinct(flatten(var.sg_public_cidrs))
  sg_private_cidrs = distinct(flatten(var.sg_private_cidrs))
  admin_cidrs      = distinct(flatten(var.admin_cidrs))

  # List of MGMT CIDRS (filtered by indexs in fgt_subnet_tags that contains string "mgmt" or "ha")
  mgmt_cidrs = [for subnet in local.mgmt_subnet_list :
    subnet["cidr"]
  ]
  # List of SGs
  sgs = merge(aws_security_group.sg_public, aws_security_group.sg_private, aws_security_group.sg_mgmt_ha)
  # List of NI sgs
  sg_ids = { for k, v in var.fgt_subnet_tags : k => local.sgs[k].id if v != "" }

  # ------------------------------------------------------------------------------------
  # Create a list of map with NI details 
  # ------------------------------------------------------------------------------------
  # Floating IP cidr host if used (FGCP cluster protocol and FGT in same AZ)
  cidr_host_floating_ip = var.cidr_host - 1
  # Config secondary IP if there is a FGCP cluster
  config_sec_ip = var.cluster_type == "fgcp" ? length(var.azs) == 1 ? true : false : false
  # List of maps with NI PUBLIC details
  ni_public_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in local.public_subnet_list : [
        for ii in range(0, var.fgt_number_peer_az) :
        { subnet_name = subnet["name"]
          subnet_cidr = subnet["cidr"]
          subnet_mask = cidrnetmask(subnet["cidr"])
          subnet_id   = subnet["id"]
          subnet_tag  = k
          ni_ip       = cidrhost(subnet["cidr"], var.cidr_host + ii)
          ni_sec_ip   = local.config_sec_ip ? ii == 0 ? cidrhost(subnet["cidr"], local.cidr_host_floating_ip) : "" : ""
          fgt_ip      = local.config_sec_ip ? cidrhost(subnet["cidr"], local.cidr_host_floating_ip) : cidrhost(subnet["cidr"], var.cidr_host + ii)
          fgt         = "fgt${ii + 1}"
          sg_id       = local.sg_ids[k]
          az          = subnet["az"]
          az_id       = subnet["az_id"]
          config_eip  = var.cluster_type != "fgcp" ? true : ii == 0 ? subnet["az"] == "az1" ? true : false : false
        }
      ] if one(slice(split(".", k), 1, 2)) == local.tag_public
    ] if v != ""
    ]
  )
  # List of maps with NI MGMT details
  ni_private_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in local.private_subnet_list : [
        for ii in range(0, var.fgt_number_peer_az) :
        { subnet_name = subnet["name"]
          subnet_cidr = subnet["cidr"]
          subnet_mask = cidrnetmask(subnet["cidr"])
          subnet_id   = subnet["id"]
          subnet_tag  = k
          ni_ip       = cidrhost(subnet["cidr"], var.cidr_host + ii)
          ni_sec_ip   = local.config_sec_ip ? ii == 0 ? cidrhost(subnet["cidr"], local.cidr_host_floating_ip) : "" : ""
          fgt_ip      = local.config_sec_ip ? cidrhost(subnet["cidr"], local.cidr_host_floating_ip) : cidrhost(subnet["cidr"], var.cidr_host + ii)
          fgt         = "fgt${ii + 1}"
          sg_id       = local.sg_ids[k]
          az          = subnet["az"]
          az_id       = subnet["az_id"]
          config_eip  = false
        }
      ] if one(slice(split(".", k), 1, 2)) == local.tag_private
    ] if v != ""
    ]
  )
  # List of maps with NI MGMT details
  ni_mgmt_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in local.mgmt_subnet_list : [
        for ii in range(0, var.fgt_number_peer_az) :
        { subnet_name = subnet["name"]
          subnet_cidr = subnet["cidr"]
          subnet_mask = cidrnetmask(subnet["cidr"])
          subnet_id   = subnet["id"]
          subnet_tag  = k
          ni_ip       = cidrhost(subnet["cidr"], var.cidr_host + ii)
          ni_sec_ip   = ""
          fgt_ip      = cidrhost(subnet["cidr"], var.cidr_host + ii)
          fgt         = "fgt${ii + 1}"
          sg_id       = local.sg_ids[k]
          az          = subnet["az"]
          az_id       = subnet["az_id"]
          config_eip  = var.config_eip_to_mgmt
        }
      ] if one(slice(split(".", k), 1, 2)) == local.tag_mgmt
    ] if v != ""
    ]
  )
  # List of maps with NI MGMT details
  ni_ha_list = flatten([
    for k, v in var.fgt_subnet_tags : [
      for i, subnet in local.ha_subnet_list : [
        for ii in range(0, var.fgt_number_peer_az) :
        { subnet_name = subnet["name"]
          subnet_cidr = subnet["cidr"]
          subnet_mask = cidrnetmask(subnet["cidr"])
          subnet_id   = subnet["id"]
          subnet_tag  = k
          ni_ip       = cidrhost(subnet["cidr"], var.cidr_host + ii)
          ni_sec_ip   = ""
          fgt_ip      = cidrhost(subnet["cidr"], var.cidr_host + ii)
          fgt         = "fgt${ii + 1}"
          sg_id       = local.sg_ids[k]
          az          = subnet["az"]
          az_id       = subnet["az_id"]
          config_eip  = false
        }
      ] if one(slice(split(".", k), 1, 2)) == local.tag_ha
    ] if v != ""
    ]
  )
  # List of maps with NI details to create aws_eip resources
  ni_eip_list = concat(local.ni_public_list, local.ni_mgmt_list)
  # List of maps with NI details to create aws_network_interface
  ni_list = concat(local.ni_public_list, local.ni_private_list, local.ni_mgmt_list, local.ni_ha_list)

  # ------------------------------------------------------------------------------------
  # OutPuts
  # ------------------------------------------------------------------------------------
  # Map with each FGT detail including list of NI IDs and EIPs (used to create other output locals)
  fgt_ni_detail = {
    for k, v in local.fgt_peer_az :
    "${v["az"]}.${v["fgt"]}" => [
      for i, ni in local.ni_list :
      { id     = lookup(aws_network_interface.nis, "${ni["az"]}.${ni["fgt"]}.${ni["subnet_tag"]}", { id = "" }).id
        ip     = ni["ni_ip"]
        sec_ip = ni["ni_sec_ip"]
        fgt_ip = ni["fgt_ip"]
        mask   = ni["subnet_mask"]
        gw     = cidrhost(ni["subnet_cidr"], 1)
        cidr   = ni["subnet_cidr"]
        tag    = ni["subnet_tag"]
        az     = ni["az"]
        az_id  = ni["az_id"]
        fgt    = ni["fgt"]
        sg_id  = ni["sg_id"]
        eip    = lookup(aws_eip.eips, "${ni["az"]}.${ni["fgt"]}.${ni["subnet_tag"]}", { public_ip = "" }).public_ip
      } if ni["az"] == v["az"] && ni["fgt"] == v["fgt"]
    ]
  }
  # Map with each FGT NI config details
  o_fgt_ports_config = {
    for k, v in local.fgt_peer_az :
    "${v["az"]}.${v["fgt"]}" => [
      for i, ni in local.ni_list :
      { port = join(".", slice(split(".", ni["subnet_tag"]), 0, 1))
        ip   = ni["fgt_ip"]
        mask = ni["subnet_mask"]
        gw   = cidrhost(ni["subnet_cidr"], 1)
        tag  = join(".", slice(split(".", ni["subnet_tag"]), 1, 2))
      } if ni["az"] == v["az"] && ni["fgt"] == v["fgt"]
    ]
  }
  # Map with each FGT detail including list of NI IDs and EIPs
  o_fgt_ni_list = {
    for i, v in local.fgt_peer_az :
    "${v["az"]}.${v["fgt"]}" =>
    { fgt         = v["fgt"]
      az_id       = local.az_map[v["az"]]
      az          = v["az"]
      public_eips = compact([for k, ni in local.fgt_ni_detail["${v["az"]}.${v["fgt"]}"] : ni["eip"] if strcontains(one(slice(split(".", ni["tag"]), 1, 2)), local.tag_public)])
      mgmt_eips   = compact([for k, ni in local.fgt_ni_detail["${v["az"]}.${v["fgt"]}"] : ni["eip"] if strcontains(one(slice(split(".", ni["tag"]), 1, 2)), local.tag_mgmt)])
      ni_ids      = compact([for k, ni in local.fgt_ni_detail["${v["az"]}.${v["fgt"]}"] : ni["id"]])
    }
  }
  # Map of FGT EIPs
  o_fgt_eips_map = {
    for k, v in local.ni_public_list :
    "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}" => lookup(aws_eip.eips, "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}", { public_ip = "" }).public_ip if v["config_eip"]
  }
  # Map with each FGT NI IP peer AZ
  o_fgt_ips_map = {
    for i, v in local.fgt_peer_az :
    "${v["az"]}.${v["fgt"]}" => {
      for k, ni in local.fgt_ni_detail["${v["az"]}.${v["fgt"]}"] :
      ni["tag"] => ni["fgt_ip"]
    }
  }
  # Map with each FGT NI ID peer AZ
  o_fgt_ids_map = {
    for i, v in local.fgt_peer_az :
    "${v["az"]}.${v["fgt"]}" => {
      for k, ni in local.fgt_ni_detail["${v["az"]}.${v["fgt"]}"] :
      ni["tag"] => ni["id"]
    }
  }
  # ------------------------------------------------------------------------------------
  # Beta - Testing
  # ------------------------------------------------------------------------------------
  /*
  # Map with each FGT NI IP peer AZ
  o_fgt_ips_map = {
    for k, v in local.ni_list : 
    "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}" =>  compact([v["ni_ip"], v["ni_sec_ip"]]) 
  }
  # Map of FGT EIPs
  o_fgt_ids_map = {
    for k, v in local.ni_list : 
    "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}" => lookup(aws_network_interface.nis, "${ni["az"]}.${ni["fgt"]}.${ni["subnet_tag"]}", { id = "" }).id 
  }
 */
}