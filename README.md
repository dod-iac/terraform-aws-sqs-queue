<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an AWS SQS queue.

```hcl
module "sqs_queue" {
  source = "dod-iac/sqs-queue/aws"

  name = format("app-%s-%s", var.application, var.environment)
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

Creates an AWS SQS queue with messages encrypted using a custom KMS key.

```hcl
module "sqs_kms_key" {
  source  = "dod-iac/sqs-kms-key/aws"

  name = format("alias/app-%s-sqs-%s", var.application, var.environment)
  description = format("A KMS key used to encrypt messages in SQS queues for %s:%s.", var.application, var.environment)
  principals = [aws_iam_role.main.arn]
  tags = local.project_tags
}

data "aws_iam_policy_document" "policy" {
  policy_id = "queue-policy"
  statement {
    sid = "AllowPrincipals"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
      ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.main.arn]
    }
    resources = [format(
      "arn:%s:sqs:%s:%s:app-%s-%s",
      data.aws_partition.current.partition,
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      var.application,
      var.environment
    )]
  }
}

module "sqs_queue" {
  source = "dod-iac/sqs-queue/aws"

  kms_key_arn = module.sqs_kms_key.aws_kms_key_arn
  name = format("app-%s-%s", var.application, var.environment)
  policy = data.aws_iam_policy_document.policy.json
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Testing

Run tests using the `terratest` script.  If using `aws-vault` you could use, `aws-vault exec AWS_PROFILE -- terratest`.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of the KMS key used to encrypt messages at-rest. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the SQS queue. | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | The JSON policy for the SQS queue. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the SQS queue. | `map(string)` | `{}` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the queue. |
| <a name="output_url"></a> [url](#output\_url) | The url of the queue. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
