#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "fgt_mgmt" {
  value = {
    fgt1_mgmt   = "https://${one(module.fgt_nis.fgt_ni_list["az1.fgt1"]["mgmt_eips"])}:${local.admin_port}"
    fgt2_mgmt   = "https://${one(module.fgt_nis.fgt_ni_list["az2.fgt1"]["mgmt_eips"])}:${local.admin_port}"
    fgt_user    = "admin"
    fgt1_pwd    = element(module.fgt.fgt_list, 0).id
    fgt2_pwd    = element(module.fgt.fgt_list, 1).id
    fgt1_public = one(module.fgt_nis.fgt_ni_list["az1.fgt1"]["public_eips"])
  }
}

output "faz-fmg" {
  value = {
    faz = module.faz.public_ip
    fmg = module.fmg.public_ip
  }
}
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