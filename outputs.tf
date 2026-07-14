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