resource "aws_s3_bucket" "logs_alb_s3" {
  bucket        = var.tf_logs_alb_bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "alb_logs_bucket" {
  bucket = aws_s3_bucket.logs_alb_s3.id
  policy = data.aws_iam_policy_document.s3_bucket_alb_write.json
}

data "aws_iam_policy_document" "s3_bucket_alb_write" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.logs_alb_s3.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.logs_alb_s3.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.logs_alb_s3.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
