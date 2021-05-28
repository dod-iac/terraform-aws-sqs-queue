/**
 * ## Usage
 *
 * Creates an AWS SQS queue.
 *
 * ```hcl
 * module "sqs_queue" {
 *   source = "dod-iac/sqs-queue/aws"
 *
 *   name = format("app-%s-%s", var.application, var.environment)
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * Creates an AWS SQS queue with messages encrypted using a custom KMS key.
 *
 * ```hcl
 * module "sqs_kms_key" {
 *   source  = "dod-iac/sqs-kms-key/aws"
 *
 *   name = format("alias/app-%s-sqs-%s", var.application, var.environment)
 *   description = format("A KMS key used to encrypt messages in SQS queues for %s:%s.", var.application, var.environment)
 *   principals = [aws_iam_role.main.arn]
 *   tags = local.project_tags
 * }
 *
 *
 * data "aws_iam_policy_document" "policy" {
 *   policy_id = "queue-policy"
 *   statement {
 *     sid = "AllowPrincipals"
 *     actions = [
 *       "sqs:SendMessage",
 *       "sqs:GetQueueAttributes",
 *       "sqs:ReceiveMessage",
 *       "sqs:DeleteMessage"
 *       ]
 *     effect = "Allow"
 *     principals {
 *       type        = "AWS"
 *       identifiers = [aws_iam_role.main.arn]
 *     }
 *     resources = [format(
 *       "arn:%s:sqs:%s:%s:app-%s-%s",
 *       data.aws_partition.current.partition,
 *       data.aws_region.current.name,
 *       data.aws_caller_identity.current.account_id,
 *       var.application,
 *       var.environment
 *     )]
 *   }
 * }
 *
 * module "sqs_queue" {
 *   source = "dod-iac/sqs-queue/aws"
 *
 *   kms_key_arn = module.sqs_kms_key.aws_kms_key_arn
 *   name = format("app-%s-%s", var.application, var.environment)
 *   policy = data.aws_iam_policy_document.policy.json
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Testing
 *
 * Run tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION`, `TT_ACCOUNT_ID`, and `TT_USER_ARN` environment variables are required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_sqs_queue" "main" {
  name                       = var.name
  kms_master_key_id          = length(var.kms_key_arn) > 0 ? var.kms_key_arn : null
  policy                     = length(var.policy) > 0 ? var.policy : null
  tags                       = var.tags
  visibility_timeout_seconds = var.visibility_timeout_seconds
}
