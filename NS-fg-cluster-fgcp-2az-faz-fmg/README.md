# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {

  azs                = ["eu-west-1a"] // List of AZs to deploy
  fgt_number_peer_az = 2              // choose number of fortigate instances to deploy peer AZ
  fgt_cluster_type   = "fgsp"         // choose type of cluster either fgsp or fgcp  

  # fgt_tags -> used in tag subnet names (these values are defined as default in module fgt_ni_sg)
  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha-sync"
  }

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - port1, port2 ... mach with fortigate instance ports
  # - public, private, mgmt ... are the values for tags choosen ih local.subnet_tags
  fgt_subnet_tags = {
    "port1.${local.subnet_tags["public"]}"  = "untrusted"
    "port2.${local.subnet_tags["private"]}" = "trusted"
    "port3.${local.subnet_tags["mgmt"]}"    = "mgmt" // leave blank or don't add this element to not create a MGMT port
    "port4.${local.subnet_tags["ha"]}"      = ""     // leave blank or don't add this element to not create a HA port
  }

  # VPC - list of public and private subnet names (include names selected in local.fgt_subnet_tags)
  public_subnet_names  = [local.fgt_subnet_tags["port1.public"], local.fgt_subnet_tags["port3.mgmt"], "bastion"]
  private_subnet_names = [local.fgt_subnet_tags["port2.private"], local.fgt_subnet_tags["port4.ha-sync"], "tgw", "gwlb"]
}

module "example" {
  source = "../fgt"

  prefix   = local.prefix
  keypair  = "eu-west-1-key-name"
  
  fgt_ni_list   = local.fgt_ni_list
  fgt_config    = local.fgt_config

  license_type  = "byol"
  instance_type = "c6i.large"
  fgt_build     = "build1575"
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


