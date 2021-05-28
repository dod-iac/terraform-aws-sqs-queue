// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

module "sqs_kms_key" {
  source  = "dod-iac/sqs-kms-key/aws"
  version = "1.0.0"

  name        = format("alias/sqs-%s", var.test_name)
  description = format("Test %s", var.test_name)

  principals = flatten([
    format(
      "arn:%s:iam::%s:root",
      data.aws_partition.current.partition,
      var.account_id,
    ),
  ])

  tags = var.tags
}

data "aws_iam_policy_document" "sqs_policy" {
  policy_id = "queue-policy"
  statement {
    sid = "AllowSendMessage"
    actions = [
      "sqs:SendMessage"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          var.account_id
        )
      ]
    }
    resources = [format(
      "arn:%s:sqs:%s:%s:%s",
      data.aws_partition.current.partition,
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      var.test_name
    )]
  }
}

module "sqs_queue" {
  source  = "../../"

  kms_key_arn = module.sqs_kms_key.aws_kms_key_arn
  name = var.test_name
  policy = data.aws_iam_policy_document.sqs_policy.json
}
