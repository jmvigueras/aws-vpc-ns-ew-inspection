# Terraform Module: Fortigate instance

This module create Fortigate instances, adding bootstrap configuration using cloud-init user-data and list of interfaces provided as variable. Type of instance, FortiOS version is also a custom parameters. 

## Usage

> [!TIP]
> Check default values for input varibles if you don't want to provide all.

```hcl
locals {
  prefix      = "test"

  fgt_ni_list   = module.fgt_nis.fgt_ni_list
  fgt_config    = {for k, v in module.fgt_config.fgt_config : k => v.fgt_config}
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
| [aws_iam_instance_profile.fgt_apicall_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.fgt_apicall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.fgt-apicall-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.fgt_apicall_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.fgt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami_ids.fgt_amis_byol](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids) | data source |
| [aws_ami_ids.fgt_amis_payg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fgt_build"></a> [fgt\_build](#input\_fgt\_build) | Fortigate VM version (default build1575 -> FortiOS 7.2.6) | `string` | `"build1575"` | no |
| <a name="input_fgt_config"></a> [fgt\_config](#input\_fgt\_config) | Map of string peer each FGT instance user-data | `map(string)` | `{}` | no |
| <a name="input_fgt_ni_list"></a> [fgt\_ni\_list](#input\_fgt\_ni\_list) | List of FortiGate details with NI IDs | `map(any)` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Provide the instance type for the FortiGate instances | `string` | `"c6i.large"` | no |
| <a name="input_keypair"></a> [keypair](#input\_keypair) | Provide the name of the keypair to use | `string` | `"null"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type to create Fortigate instnace, either byol or payg | `string` | `"payg"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Provide a common tag prefix value that will be used in the name tag for all resources | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, necessay if provider alias is used | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for created resources | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt_list"></a> [fgt\_list](#output\_fgt\_list) | List of FortiGate details |
| <a name="output_fgt_peer_az_ids"></a> [fgt\_peer\_az\_ids](#output\_fgt\_peer\_az\_ids) | IDs of FortiGate instances in each Availability Zone |
<!-- END_TF_DOCS -->