# Terraform Module: Fortigate network interfaces and security groups

Create all Fortigate instance Network Interfaces and Security Groups, it will take into account type of cluster, AZ to deploy, number of Fortigates and so on. 

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
  azs         = ["eu-west-1a","eu-west-1b"]

  subnet_tags = {
    "public"  = "public"
    "private" = "private"
    "mgmt"    = "mgmt"
    "ha"      = "ha"
  }
  fgt_subnet_tags = {
    "port0.public"  = "subnet-public"
    "port1.private" = "subnet-private"
    "port2.mgmt"    = "subnet-mgmt"
  }
  cluster_type = "fgcp" 

  vpc_id       = module.vpc.vpc_id
  subnet_list  = module.vpc.subnet_list
}

module "example" {
  source = "../aws_fgt_ni_sg"

  prefix             = local.prefix
  azs                = local.azs
  vpc_id             = local.vpc_id
  subnet_list        = local.subnet_list
  fgt_subnet_tags    = local.fgt_subnet_tags     
  fgt_number_peer_az = 1
  cluster_type       = local.cluster_type
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
| [aws_eip.eips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_network_interface.nis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.sg_mgmt_ha](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | CIDR for the administrative access to Fortigates | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | Port for the administrative access to Fortigates | `string` | `"8443"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones where Fortigates will be deployed | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1c"<br>]</pre> | no |
| <a name="input_cidr_host"></a> [cidr\_host](#input\_cidr\_host) | First IP number of the network to assign | `number` | `10` | no |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | Type of cluster Fortigates will use, either fgcp or fgsp | `string` | `""` | no |
| <a name="input_config_eip_to_mgmt"></a> [config\_eip\_to\_mgmt](#input\_config\_eip\_to\_mgmt) | Enable EIP to MGMT interface if true | `bool` | `true` | no |
| <a name="input_fgt_number_peer_az"></a> [fgt\_number\_peer\_az](#input\_fgt\_number\_peer\_az) | Number of Fortigates in each AZ | `number` | `1` | no |
| <a name="input_fgt_subnet_tags"></a> [fgt\_subnet\_tags](#input\_fgt\_subnet\_tags) | Subnet tags map assigned to each subnet, must much with variable subnet\_tags | `map(string)` | <pre>{<br>  "port0.public": "subnet-public",<br>  "port1.private": "subnet-private",<br>  "port2.mgmt": "subnet-mgmt"<br>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_subnet_list"></a> [subnet\_list](#input\_subnet\_list) | List of subnets where Fortigates will be deployed | `list(map(string))` | <pre>[<br>  {}<br>]</pre> | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Tag used to define each type of subnet, needed: public, private, mgmt and ha | `map(string)` | <pre>{<br>  "ha": "ha-sync",<br>  "mgmt": "mgmt",<br>  "private": "private",<br>  "public": "public"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where Fortigates will be deployed | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt_eips_map"></a> [fgt\_eips\_map](#output\_fgt\_eips\_map) | Map of FortiGate Elastic IPs |
| <a name="output_fgt_ids_map"></a> [fgt\_ids\_map](#output\_fgt\_ids\_map) | Map of FortiGate network interfaces IDs |
| <a name="output_fgt_ips_map"></a> [fgt\_ips\_map](#output\_fgt\_ips\_map) | n/a |
| <a name="output_fgt_ni_list"></a> [fgt\_ni\_list](#output\_fgt\_ni\_list) | List of FortiGate network interfaces |
| <a name="output_fgt_ports_config"></a> [fgt\_ports\_config](#output\_fgt\_ports\_config) | List of FortiGate ports configuration details |
<!-- END_TF_DOCS -->
