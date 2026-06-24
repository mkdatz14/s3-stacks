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

provider "aws" "this" {
  config {
    region = var.aws_region
  }
}

provider "random" "this" {}

component "s3_bucket" {
  source = "./modules/s3_bucket"

  inputs = {
    project              = var.project
    environment          = var.environment
    bucket_purpose       = var.bucket_purpose
    bucket_name_override = var.bucket_name_override
    force_destroy        = var.force_destroy
    versioning_enabled   = var.versioning_enabled
    sse_algorithm        = var.sse_algorithm
    bucket_key_enabled   = var.bucket_key_enabled
    lifecycle_rules      = var.lifecycle_rules
    tags                 = var.tags
  }

  providers = {
    aws    = provider.aws.this
    random = provider.random.this
  }
}
