resource "aws_security_group" "sg_allow_all_admin_cidrs" {
  name        = "${var.prefix}-sg-allow-admin-cidr-rfc1918"
  description = "Allow all traffic from RFC1918 and admin_cidr"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = distinct(flatten(var.admin_cidrs))
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = distinct(flatten(var.admin_cidrs))
  }
  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = distinct(flatten(var.admin_cidrs))
  }
  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = distinct(flatten(var.admin_cidrs))
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-sg-allow-all-admin-cidrs" }
  )
}