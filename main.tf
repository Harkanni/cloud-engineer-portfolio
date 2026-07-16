data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_policy_document" "allow_cloudfront" {
  statement {
    sid = "AllowCloudFrontService"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.cloud_dev_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.s3_distribution.arn
      ]
    }
  }
}

# 1. S3 Bucket Configuration
resource "aws_s3_bucket" "cloud_dev_bucket" {
  bucket = "cloud-engineer-portfolio-bucket-v2"

  tags = {
    "Name"        = "Cloud Engineer Portfolio"
    "version"     = "1.0"
    "Environment" = "Development"
  }
}

# resource "aws_s3_bucket_ownership_controls" "cloud_dev_bucket" {
#   bucket = aws_s3_bucket.cloud_dev_bucket.id

#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }

resource "aws_s3_bucket_public_access_block" "cloud_dev_bucket" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# 2. CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-portfolio-oac"
  description                       = "OAC for private portfolio S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 3. CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.cloud_dev_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = "S3-${aws_s3_bucket.cloud_dev_bucket.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html" # Crucial step: automatically serves index.html

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.cloud_dev_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "Development"
  }
}

# 4. S3 Bucket Policy (Gives CloudFront secure permission to fetch files)
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.cloud_dev_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudfront.json
}

# 5. S3 Object Uploads
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.cloud_dev_bucket.id
  key          = "index.html"
  source       = "www/index.html"
  content_type = "text/html"
  etag         = filemd5("www/index.html")
}

resource "aws_s3_object" "favicons" {
  for_each = toset(local.favicon_files)

  bucket       = aws_s3_bucket.cloud_dev_bucket.id
  key          = "favicon/${each.value}"
  source       = "www/favicon/${each.value}"
  content_type = "image/x-icon"
  etag         = filemd5("www/favicon/${each.value}")
}
