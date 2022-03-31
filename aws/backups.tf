resource "aws_iam_user" "backups" {
  name = "backup-scripts"
}

resource "aws_iam_user_policy_attachment" "backups" {
  user       = aws_iam_user.backups.name
  policy_arn = aws_iam_policy.backups.arn
}

/* ************************************************************************* */

resource "aws_s3_bucket" "backups" {
  bucket = "barrucadu-backups"
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "backups" {
  bucket = aws_s3_bucket.backups.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = 32
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 64
      storage_class = "GLACIER"
    }
  }
}

/* ************************************************************************* */

resource "aws_iam_policy" "backups" {
  name        = "backups"
  description = "R/W access to the backup bucket, though no permission to delete old versions."
  policy      = data.aws_iam_policy_document.backups.json
}

data "aws_iam_policy_document" "backups" {
  statement {
    sid = "InspectBuckets"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    sid = "ManageBackups"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.backups.arn,
      "${aws_s3_bucket.backups.arn}/*",
    ]
  }
}
