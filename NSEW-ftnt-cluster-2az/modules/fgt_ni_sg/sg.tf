# ------------------------------------------------------------------
# Create Security Groups for each FGT NI
# ------------------------------------------------------------------
# SG Public Subnets
resource "aws_security_group" "sg_public" {
  for_each = { for k, v in var.fgt_subnet_tags : k => v if strcontains(k, local.tag_public) }

  name        = "${var.prefix}-sg-${each.key}"
  description = "Allow all traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.sg_public_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "${var.prefix}-sg-${each.key}" },
  var.tags)
}
# SG Private Subnets
resource "aws_security_group" "sg_private" {
  for_each = { for k, v in var.fgt_subnet_tags : k => v if strcontains(k, local.tag_private) }

  name        = "${var.prefix}-sg-${each.key}"
  description = "Allow all connections from RFC1918"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.sg_private_cidrs
  }
  egress {
    description = "Allow all traffic outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "${var.prefix}-sg-${each.key}" },
    var.tags
  )
}
# SG MGMT and HA NI
resource "aws_security_group" "sg_mgmt_ha" {
  for_each = { for k, v in var.fgt_subnet_tags : k => v if strcontains(k, local.tag_mgmt) || strcontains(k, local.tag_ha) }

  name        = "${var.prefix}-sg-${each.key}"
  description = "Allow MGMT SSH, HTTPS and ICMP traffic and all between FGT"
  vpc_id      = var.vpc_id

  ingress {
    description = "FGT SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidrs
  }
  ingress {
    description = "FGT admin port Registration"
    from_port   = 541
    to_port     = 541
    protocol    = "tcp"
    cidr_blocks = local.admin_cidrs
  }
  ingress {
    description = "ForitManager port AV/IPS Push"
    from_port   = 9443
    to_port     = 9443
    protocol    = "udp"
    cidr_blocks = local.admin_cidrs
  }
  ingress {
    description = "Allow all from FGT MGMT subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.mgmt_cidrs
  }
  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = local.admin_cidrs
  }
  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = local.admin_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "${var.prefix}-sg-${each.key}" },
    var.tags
  )
}