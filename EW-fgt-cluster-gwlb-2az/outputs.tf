#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_mgmt" {
  value = {
    fgt1_mgmt = "https://${one(module.ew_fgt_nis.fgt_ni_list["az1.fgt1"]["public_eips"])}:${local.admin_port}"
    fgt2_mgmt = "https://${one(module.ew_fgt_nis.fgt_ni_list["az2.fgt1"]["public_eips"])}:${local.admin_port}"
    fgt_user  = "admin"
    fgt1_pwd  = element(module.ew_fgt.fgt_list, 0).id
    fgt2_pwd  = element(module.ew_fgt.fgt_list, 1).id
  }
}

/*
#-------------------------------
# Debugging 
#-------------------------------
output "fgt_ni_list" {
  value = module.ew_fgt_nis.fgt_ni_list
}

output "ni_list" {
  value = module.ew_fgt_nis.ni_list
}

output "fgt_ni_ports_config" {
  value = module.ew_fgt_nis.fgt_ports_config
}

output "fgt_vpc_subnets_ids" {
  value = module.fgt_vpc.subnet_ids
}

output "vpc_services_rt_ids" {
  value = module.vpc_services.rt_private_ids
}

output "gwlbe_subnets_ids" {
  value = { for i, v in local.azs : "servers-az${i + 1}" => lookup(module.vpc_services.subnet_ids["az${i + 1}"], "gwlbe", "") }
}

output "gwlb_endpoint" {
  value = module.gwlb_endpoint
}
*/