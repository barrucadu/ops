resource "aws_iam_user" "concourse" {
  name = "concourse"
}

resource "aws_iam_user_policy_attachment" "concourse" {
  user       = aws_iam_user.concourse.name
  policy_arn = aws_iam_policy.concourse.arn
}

/* ************************************************************************* */

resource "aws_kms_key" "concourse" {
  description = "Key for Concourse secrets"
}

/* ************************************************************************* */

locals {
  concourse_ip_addresses = ["94.130.74.147/32", "2a01:4f8:c0c:77b3::/64"]
}

resource "aws_iam_policy" "concourse" {
  name        = "concourse"
  description = "R/W access to the /concourse SSM Parameter Store namespace, with an encryption key."
  policy      = data.aws_iam_policy_document.concourse.json
}

data "aws_iam_policy_document" "concourse" {
  statement {
    sid = "ManageSecrets"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParametersByPath",
      "ssm:PutParameter",
    ]

    resources = [
      # "arn:aws:ssm:::parameter/..." doesn't seem to work in this
      # policy, but specifying the account ID explicitly does.
      "arn:aws:ssm:eu-west-1:${var.aws_account_id}:parameter/concourse",
      "arn:aws:ssm:eu-west-1:${var.aws_account_id}:parameter/concourse/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = local.concourse_ip_addresses
    }
  }

  statement {
    sid = "UseEncryptionKey"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      aws_kms_key.concourse.arn
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = local.concourse_ip_addresses
    }
  }

  statement {
    sid = "InspectEncryptionKeys"

    actions = [
      "kms:ListAliases",
      "kms:ListKeys",
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = local.concourse_ip_addresses
    }
  }
}
