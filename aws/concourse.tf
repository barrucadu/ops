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
  }
}
