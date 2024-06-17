# Terraform Module: Routes within route tables

Create a default route within a Route Tables specified in inputs variables and destination block (default 0.0.0.0/0)

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  azs    = ["eu-west-1a", "eu-west-1c"]
  
  ni_rt_subnet_names  = ["bastion", "tgw"]
  tgw_rt_subnet_names = ["private"]

  # Create map of RT IDs where add routes pointing to a FGT NI
  ni_rt_ids = {
    for pair in setproduct(local.ni_rt_subnet_names,[for i, az in local.eu_azs : "az${i+1}"]) : 
    "${pair[0]}-${pair[1]}" => module.eu_hub_vpc.rt_ids[pair[1]][pair[0]] 
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  tgw_rt_ids = {
    for pair in setproduct(local.tgw_rt_subnet_names,[for i, az in local.eu_azs : "az${i+1}"]) : 
    "${pair[0]}-${pair[1]}" => module.eu_hub_vpc.rt_ids[pair[1]][pair[0]] 
  }
}

module "example" {
  source = "../aws_vpc"

  tgw_id = module.tgw.tgw_id
  ni_id  = module.fgt_nis.fgt_ids_map["az1.fgt1"]["private"]

  ni_rt_ids  = local.ni_rt_ids
  tgw_rt_ids = local.tgw_rt_ids
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.r_private_to_core_net_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.r_private_to_gwlb_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.r_private_to_ni_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.r_private_to_tgw_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | Created for future use | `string` | `"0.0.0.0/0"` | no |
| <a name="input_core_network_arn"></a> [core\_network\_arn](#input\_core\_network\_arn) | AWS Core Network ARN to use in routes | `string` | `null` | no |
| <a name="input_core_network_rt_ids"></a> [core\_network\_rt\_ids](#input\_core\_network\_rt\_ids) | List of Route Tables ID to add private routes to a Core Network Endpoint | `map(string)` | `{}` | no |
| <a name="input_destination_cidr_block"></a> [destination\_cidr\_block](#input\_destination\_cidr\_block) | Default destination block of created new routes | `string` | `"0.0.0.0/0"` | no |
| <a name="input_gwlb_rt_ids"></a> [gwlb\_rt\_ids](#input\_gwlb\_rt\_ids) | List of Route Tables ID to add private routes to a GWLB Endpoint | `map(string)` | `{}` | no |
| <a name="input_gwlbe_id"></a> [gwlbe\_id](#input\_gwlbe\_id) | AWS GWLB endpoint ID to use in routes | `string` | `null` | no |
| <a name="input_ni_id"></a> [ni\_id](#input\_ni\_id) | AWS instance NI ID to use in routes | `string` | `null` | no |
| <a name="input_ni_rt_ids"></a> [ni\_rt\_ids](#input\_ni\_rt\_ids) | List of Route Tables ID to add private routes to a Network Interface | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_tgw_id"></a> [tgw\_id](#input\_tgw\_id) | AWS TGW ID to use in routes | `string` | `null` | no |
| <a name="input_tgw_rt_ids"></a> [tgw\_rt\_ids](#input\_tgw\_rt\_ids) | List of Route Tables ID to add private routes to a TGW | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->