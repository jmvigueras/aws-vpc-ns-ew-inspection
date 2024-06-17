# ------------------------------------------------------------------
# Create Instance
# ------------------------------------------------------------------
resource "aws_instance" "fgt" {
  for_each = { for k, v in local.fgt_list : "${v["az"]}.${v["fgt"]}" => v }

  ami                  = var.license_type == "byol" ? data.aws_ami_ids.fgt_amis_byol.ids[0] : data.aws_ami_ids.fgt_amis_payg.ids[0]
  instance_type        = var.instance_type
  availability_zone    = each.value["az_id"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.fgt_apicall_profile.name
  user_data            = var.fgt_config[each.key]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  ebs_block_device {
    encrypted   = true
    device_name = "/dev/sdb"
  }

  dynamic "network_interface" {
    for_each = { for k, v in each.value["ni_ids"] : k => v }

    content {
      device_index         = network_interface.key
      network_interface_id = network_interface.value
    }
  }

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-${each.key}" }
  )

  volume_tags = merge(
    var.volume_tags
  )
}
# ------------------------------------------------------------------
# Data
# ------------------------------------------------------------------
# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fgt_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND ${var.fgt_build}*"]
  }
}
# Get the last AMI Images from AWS MarektPlace FGT BYOL
data "aws_ami_ids" "fgt_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS ${var.fgt_build}*"]
  }
}