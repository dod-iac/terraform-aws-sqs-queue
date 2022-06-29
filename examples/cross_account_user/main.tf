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
      identifiers = [var.user_arn]
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
  source = "../../"
  name   = var.test_name
  policy = data.aws_iam_policy_document.sqs_policy.json
}
