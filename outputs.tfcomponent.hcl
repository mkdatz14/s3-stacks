output "bucket_name" {
  description = "The created S3 bucket name."
  value       = component.s3_bucket.bucket_name
  type        = string
}

output "bucket_arn" {
  description = "The created S3 bucket ARN."
  value       = component.s3_bucket.bucket_arn
  type        = string
}

output "bucket_region" {
  description = "The AWS region where the bucket exists."
  value       = component.s3_bucket.bucket_region
  type        = string
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = component.s3_bucket.bucket_regional_domain_name
  type        = string
}
