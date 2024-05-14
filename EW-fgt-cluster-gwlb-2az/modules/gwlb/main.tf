#---------------------------------------------------------------------------
# GWLB
# - Create GWLB
# - Create Target Group
# - Create Listener 
# - Attach Fortigate IPs to target group
# - Create Endpoint Service
#---------------------------------------------------------------------------
// Create Gateway LB
resource "aws_lb" "gwlb" {
  load_balancer_type               = "gateway"
  name                             = "${var.prefix}-gwlb"
  enable_cross_zone_load_balancing = false
  subnets                          = [for k, v in var.subnet_ids : v]
}
// Create Gateway LB target group GENEVE
resource "aws_lb_target_group" "gwlb_target_group" {
  name        = "${var.prefix}-gwlb-tg"
  port        = 6081
  protocol    = "GENEVE"
  target_type = "ip"
  vpc_id      = var.vpc_id

  //slow_start           = var.slow_start
  deregistration_delay = var.deregistration_delay

  health_check {
    port     = var.backend_port
    protocol = var.backend_protocol
    interval = var.backend_interval
  }

  target_failover {
    on_deregistration = var.target_failover
    on_unhealthy      = var.target_failover
  }
}
// Create Gateway LB Listener
resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.id

  default_action {
    target_group_arn = aws_lb_target_group.gwlb_target_group.id
    type             = "forward"
  }
}
// Create nlb target group attachemnt to FGT
resource "aws_lb_target_group_attachment" "gwlb_tg_fgt" {
  for_each = { for i, ip in var.fgt_ips : i => ip } // map of FGT IPs with value FGT IP

  target_group_arn = aws_lb_target_group.gwlb_target_group.arn
  target_id        = each.value
}
// Create GWLB Service
resource "aws_vpc_endpoint_service" "gwlb_service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]

  tags = merge(
    { Name = "${var.prefix}-gwlbe-service" },
  var.tags)
}

// Principal ARN to discover GWLB Service
data "aws_caller_identity" "current" {}

// Create GWLB NI resource with NI IDs
data "aws_network_interface" "gwlb_ni" {
  #count = length(var.subnet_ids)
  for_each = var.subnet_ids
  filter {
    name   = "description"
    values = ["ELB gwy/${aws_lb.gwlb.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = ["${each.value}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "attachment.status"
    values = ["attached"]
  }
}



