data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "cloud_dev_bucket" {
  region = "us-east-1"
  bucket = "cloud-engineer-portfolio-bucket-v2"

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

  block_public_policy     = true
  restrict_public_buckets = true
}


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id
  key    = "index.html"
  source = "www/index.html"
  content_type = "text/html"

  etag = filemd5("www/index.html")
}

resource "aws_s3_object" "favicons" {
  for_each = toset(local.favicon_files)

  bucket = aws_s3_bucket.cloud_dev_bucket.id
  key = "favicon/${each.value}"
  source = "www/favicon/${each.value}"

  content_type = "image/x-icon"
  etag = filemd5("www/favicon/${each.value}")
}
