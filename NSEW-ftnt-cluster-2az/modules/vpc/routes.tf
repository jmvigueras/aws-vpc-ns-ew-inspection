#---------------------------------------------------------------------------
# Create Public Route Tables
#---------------------------------------------------------------------------
# Route Tables to public subnets
resource "aws_route_table" "rt_public" {
  for_each = { for subnet in local.subnets_public_name :
    subnet => subnet
  }

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.value}-rt-public" }
  )
}
# Default route to RTs public
resource "aws_route" "rt_public_r_default" {
  for_each = { for subnet in local.subnets_public_name :
    subnet => subnet
  }

  route_table_id         = aws_route_table.rt_public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
# Create route association to public subnets
resource "aws_route_table_association" "rta_public" {
  for_each = merge(
    { for subnet in local.subnets_public_name :
      subnet => lookup(aws_subnet.subnets, subnet, { id = "notfound" }).id
    }
  )

  subnet_id      = each.value
  route_table_id = aws_route_table.rt_public[each.key].id
}
#---------------------------------------------------------------------------
# Create Private Route Tables
#---------------------------------------------------------------------------
# Route private
resource "aws_route_table" "rt_private" {
  for_each = { for subnet in local.subnets_private_name :
    subnet => subnet
  }

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.value}-rt-private" }
  )
}
# Create route association to private subnets
resource "aws_route_table_association" "rta_private" {
  for_each = { for subnet in local.subnets_private_name :
    subnet => lookup(aws_subnet.subnets, subnet, { id = "notfound" }).id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.rt_private[each.key].id
}