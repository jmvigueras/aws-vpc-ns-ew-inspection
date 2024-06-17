#---------------------------------------------------------------------------
# Crate Route Table private to a NI
#---------------------------------------------------------------------------
# Create routes to NI in RTs
resource "aws_route" "r_private_to_ni_default" {
  for_each = var.ni_rt_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  network_interface_id   = var.ni_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a TGW
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_tgw_default" {
  for_each = var.tgw_rt_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.tgw_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a GWLBe
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_gwlb_default" {
  for_each = var.gwlb_rt_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  vpc_endpoint_id        = var.gwlbe_id
}
#---------------------------------------------------------------------------
# Crate Route Table private to a Core Network
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_core_net_default" {
  for_each = var.core_network_rt_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  core_network_arn       = var.core_network_arn
}
#---------------------------------------------------------------------------
# Crate Route Table private to NAT GW
#---------------------------------------------------------------------------
resource "aws_route" "r_private_to_natgw_default" {
  for_each = var.natgw_rt_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id         = var.natgw_id
}