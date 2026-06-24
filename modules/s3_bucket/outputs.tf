output "bucket_name" {
  description = "The created S3 bucket name."
  value       = module.bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "The created S3 bucket ARN."
  value       = module.bucket.s3_bucket_arn
}

output "bucket_region" {
  description = "The AWS region where the bucket exists."
  value       = module.bucket.s3_bucket_region
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = module.bucket.s3_bucket_bucket_regional_domain_name
}
