# Terraform Module: Amazon VPC

Create a VPC with provided subnet names and default route tables and security groups.

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"
  region      = "eu-west-1"
  azs         = ["eu-west-1a","eu-west-1b"]
  admin_cidr  = "0.0.0.0/0"

  public_subnet_names  = ["public", "mgmt", "bastion"]
  private_subnet_names = ["private", "tgw"]
}

module "example" {
  source = "../aws_vpc"

  prefix     = local.prefix
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.vpc_cidr

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
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
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.rt_public_r_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.rt_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.rt_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rta_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.rta_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.sg_allow_admin_cidr_rfc1918](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | CIDR for the administrative access to Fortigates | `string` | `"0.0.0.0/0"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones where Fortigates will be deployed | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1c"<br>]</pre> | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | CIDR for the VPC | `string` | `"172.20.0.0/23"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | Names for private subnets | `list(string)` | <pre>[<br>  "private",<br>  "tgw"<br>]</pre> | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | Names for public subnets | `list(string)` | <pre>[<br>  "public",<br>  "bastion"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rt_ids"></a> [rt\_ids](#output\_rt\_ids) | IDs of all route tables |
| <a name="output_rt_private_ids"></a> [rt\_private\_ids](#output\_rt\_private\_ids) | IDs of private route tables |
| <a name="output_rt_public_ids"></a> [rt\_public\_ids](#output\_rt\_public\_ids) | IDs of public route tables |
| <a name="output_sg_ids"></a> [sg\_ids](#output\_sg\_ids) | IDs of security groups |
| <a name="output_subnet_arns"></a> [subnet\_arns](#output\_subnet\_arns) | List of subnets ARNs |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | CIDRs of the subnets |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | List of subnets ID |
| <a name="output_subnet_list"></a> [subnet\_list](#output\_subnet\_list) | List of subnets |
| <a name="output_subnet_private_cidrs"></a> [subnet\_private\_cidrs](#output\_subnet\_private\_cidrs) | CIDRs of private subnets |
| <a name="output_subnet_private_ids"></a> [subnet\_private\_ids](#output\_subnet\_private\_ids) | IDs of private subnets |
| <a name="output_subnet_public_cidrs"></a> [subnet\_public\_cidrs](#output\_subnet\_public\_cidrs) | CIDRs of public subnets |
| <a name="output_subnet_public_ids"></a> [subnet\_public\_ids](#output\_subnet\_public\_ids) | IDs of public subnets |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Description of the subnets |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the created VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the created VPC |
<!-- END_TF_DOCS -->