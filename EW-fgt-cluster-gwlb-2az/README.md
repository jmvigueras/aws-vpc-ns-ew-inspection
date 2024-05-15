# Example: Forigate deployment

This is an example of how to deploy fortigates using [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
locals {
  
  prefix = "ew-fgt"

  tags = {
    Project = "Fortigate VPC E-W inspection"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] //Select AZs to deploy

  # VPC - CIDR
  fgt_vpc_cidr = "10.2.0.0/24"

  # AWS cidrs ranges
  aws_cidrs = "10.0.0.0/8"

  # TGW id (provide TGW id to update route tables)
  # (if "" doesn't create route tables)
  tgw_id = ""
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


