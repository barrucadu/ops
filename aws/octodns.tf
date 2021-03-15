resource "aws_iam_user" "octodns" {
  name = "octodns"
}

resource "aws_iam_user_policy_attachment" "octodns" {
  user       = aws_iam_user.octodns.name
  policy_arn = aws_iam_policy.octodns.arn
}

/* ************************************************************************* */

resource "aws_iam_policy" "octodns" {
  name        = "octodns"
  description = "Full access to all Route53 resources."
  policy      = data.aws_iam_policy_document.octodns.json
}

data "aws_iam_policy_document" "octodns" {
  statement {
    actions = [
      "route53:*",
    ]

    resources = [
      "*",
    ]
  }
}
