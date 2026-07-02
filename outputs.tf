output "website_endpoint" {
  description = "S3 Static Website Endpoint"
  value       = aws_s3_bucket_website_configuration.cloud_dev_bucket.website_endpoint
}

output "website_domain" {
  description = "S3 Static Website Domain"
  value       = aws_s3_bucket_website_configuration.cloud_dev_bucket.website_domain
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.cloud_dev_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.cloud_dev_bucket.arn
}

output "bucket_region" {
  description = "AWS Region"
  value       = data.aws_region.current.region
}

output "bucket_id" {
  description = "Unique identifier of the S3 bucket"
  value       = aws_s3_bucket.cloud_dev_bucket.id
}