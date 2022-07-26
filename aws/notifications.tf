resource "aws_iam_user" "notifications" {
  name = "notifications"
}

resource "aws_iam_user_policy_attachment" "backups_publish_notifications" {
  user       = aws_iam_user.backups.name
  policy_arn = aws_iam_policy.notifications.arn
}

resource "aws_iam_user_policy_attachment" "notifications" {
  user       = aws_iam_user.notifications.name
  policy_arn = aws_iam_policy.notifications.arn
}

/* ************************************************************************* */

resource "aws_sns_topic" "notifications" {
  name = "host-notifications"
}

resource "aws_sns_topic_subscription" "sms" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sms"
  endpoint  = var.phone
}

## terraform cannot create the email subscription because it must be
## manually confirmed
# resource "aws_sns_topic_subscription" "email" {
#   provider  = "aws"
#   topic_arn = aws_sns_topic.notifications.arn
#   protocol  = "email"
#   endpoint  = var.email
# }

/* ************************************************************************* */

resource "aws_iam_policy" "notifications" {
  name        = "notifications"
  description = "Publish access to the host-notifications topic."
  policy      = data.aws_iam_policy_document.notifications.json
}

data "aws_iam_policy_document" "notifications" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      aws_sns_topic.notifications.arn,
    ]
  }
}
