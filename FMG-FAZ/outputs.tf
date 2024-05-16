#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "faz-fmg" {
  value = {
    faz_public_ip = module.faz.public_ip
    fmg_public_ip = module.fmg.public_ip
    faz_private_ip = module.faz.private_ip
    fmg_private_ip = module.fmg.private_ip
  }
}
/*
#-------------------------------
# Debugging 
#-------------------------------
*/