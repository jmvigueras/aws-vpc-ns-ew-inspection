#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_mgmt" {
  value = {
    fgt1_mgmt   = "https://${module.fgt_nis.fgt_ips_map["az1.fgt1"]["port3.mgmt"]}:${local.admin_port}"
    fgt2_mgmt   = "https://${module.fgt_nis.fgt_ips_map["az2.fgt1"]["port3.mgmt"]}:${local.admin_port}"
    fgt_user    = "admin"
    fgt1_pwd    = element(module.fgt.fgt_list, 0).id
    fgt2_pwd    = element(module.fgt.fgt_list, 1).id
    fgt1_public = try(module.fgt_nis.fgt_ni_list["az1.fgt1"]["public_eips"], "No Public IP")
  }
}

/*
output "faz-fmg" {
  value = {
    faz_public_ip = module.faz.public_ip
    fmg_public_ip = module.fmg.public_ip
    faz_private_ip = module.faz.private_ip
    fmg_private_ip = module.fmg.private_ip
  }
}
*/


/*
#-------------------------------
# Debugging 
#-------------------------------
output "fgt_ids" {
  value = module.fgt.fgt_list
}
output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}
output "fgt_ni_ports_config" {
  value = module.fgt_nis.fgt_ports_config
}
*/