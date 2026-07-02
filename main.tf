data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "cloud_dev_bucket" {
  region = "us-east-1"
  bucket = "cloud-engineer-portfolio-bucket"

  tags = {
    "Name" = "Cloud Engineer Portfolio"
    "version" = "1.0"
    "Environment" = "Development"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloud_dev_bucket" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cloud_dev_bucket" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true

  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cloud_dev_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [ aws_s3_bucket_public_access_block.cloud_dev_bucket ]
}


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id
  key    = "index.html"
  source = "www/index.html"
  content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("www/index.html")
}

resource "aws_s3_bucket_website_configuration" "cloud_dev_bucket" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}