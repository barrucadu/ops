locals {
  # zones are created through octodns, not terraform
  hosted_zones = {
    barrucadu_co_uk = {
      domain = "barrucadu.co.uk"
      zone_id = "ZNU9LQOCWHL2G"
    }
    barrucadu_com = {
      domain = "barrucadu.com"
      zone_id = "Z1C3JSO4U0YR4W"
    }
    barrucadu_dev = {
      domain = "barrucadu.dev"
      zone_id = "ZLNB2NX649UB7"
    }
    barrucadu_uk = {
      domain = "barrucadu.uk"
      zone_id = "Z2DLRR7BSV8HA0"
    }
  }
}

resource "aws_iam_user" "acme_dns_challenge" {
  name = "acme-dns-challenge"
}

resource "aws_iam_user_policy_attachment" "acme_dns_challenge" {
  for_each = local.hosted_zones

  user       = aws_iam_user.acme_dns_challenge.name
  policy_arn = aws_iam_policy.acme_dns_challenge[each.key].arn
}

/* ************************************************************************* */

resource "aws_iam_policy" "acme_dns_challenge" {
  for_each = local.hosted_zones

  name        = "acme-dns-challenge-${each.value.domain}"
  description = "Restricted access to the zone for ${each.value.domain}."
  policy      = data.aws_iam_policy_document.acme_dns_challenge[each.key].json
}

// https://go-acme.github.io/lego/dns/route53/index.html#least-privilege-policy-for-production-purposes
data "aws_iam_policy_document" "acme_dns_challenge" {
  for_each = local.hosted_zones

  statement {
    actions = [
      "route53:GetChange",
    ]

    resources = [
      "arn:aws:route53:::change/*",
    ]
  }
  statement {
    actions = [
      "route53:ListHostedZonesByName",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${each.value.zone_id}",
    ]
  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${each.value.zone_id}",
    ]

    condition {
      test = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = ["_acme-challenge.${each.value.domain}"]
    }

    condition {
      test = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values = ["TXT"]
    }
  }
}
