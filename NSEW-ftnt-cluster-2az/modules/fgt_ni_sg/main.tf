# ------------------------------------------------------------------
# Create Network Interfaces (public and private)
# ------------------------------------------------------------------
# Create EIP public NI
# - Creeat EIP associated to NI if config_eip is true
resource "aws_eip" "eips" {
  depends_on = [resource.aws_network_interface.nis]
  for_each   = { for k, v in local.ni_eip_list : "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}" => v if v["config_eip"] }

  domain                    = "vpc"
  network_interface         = aws_network_interface.nis[each.key].id
  associate_with_private_ip = each.value["ni_sec_ip"] != "" ? each.value["ni_sec_ip"] : each.value["ni_ip"]

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.key}-eip-ni" }
  )
}
# Create NIs based on NI list
resource "aws_network_interface" "nis" {
  for_each = { for k, v in local.ni_list : "${v["az"]}.${v["fgt"]}.${v["subnet_tag"]}" => v }

  subnet_id       = each.value["subnet_id"]
  security_groups = [each.value["sg_id"]]
  private_ip_list = compact([each.value["ni_ip"], each.value["ni_sec_ip"]])

  source_dest_check       = false
  private_ip_list_enabled = true

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.key}-ni" }
  )
}