terraform {
  required_version = ">= 1.15.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.51"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 3

  keepers = {
    bucket_name_override = var.bucket_name_override
    bucket_purpose       = var.bucket_purpose
    environment          = var.environment
    project              = var.project
  }
}

locals {
  generated_bucket_name = lower("${var.project}-${var.environment}-${var.bucket_purpose}-${random_id.bucket_suffix.hex}")
  bucket_name           = var.bucket_name_override != "" ? var.bucket_name_override : local.generated_bucket_name

  lifecycle_rules = [
    for rule in var.lifecycle_rules : merge(
      {
        id      = rule.id
        enabled = rule.enabled
      },
      try(rule.expiration, null) != null ? { expiration = rule.expiration } : {},
      try(rule.transition, null) != null ? { transition = rule.transition } : {}
    )
  ]

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project
      Purpose     = var.bucket_purpose
    }
  )
}

module "bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.14.1"

  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = var.sse_algorithm
      }
      bucket_key_enabled = var.bucket_key_enabled
    }
  }

  lifecycle_rule = local.lifecycle_rules

  tags = local.tags
}
