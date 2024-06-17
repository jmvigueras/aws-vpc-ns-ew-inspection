# ------------------------------------------------------------------------------------
# Create VPC
# ------------------------------------------------------------------------------------
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-vpc" }
  )
}
# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-igw" }
  )
}
# Subnets peer AZ
resource "aws_subnet" "subnets" {
  for_each = local.subnets_map

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.key}" }
  )
}
