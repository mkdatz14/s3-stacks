# Each deployment is an independent instance of the Stack with its own state.
# These mirror the nine S3 workspaces in s3-example-app.

deployment "dev-1" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "dev-1"
    bucket_purpose     = "app-logs"
    force_destroy      = true
    versioning_enabled = false
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "expire-dev-logs"
        enabled = true
        expiration = {
          days = 30
        }
      }
    ]

    tags = {
      CostCenter = "sandbox"
      Owner      = "platform-team"
      Tier       = "dev"
    }
  }
}

deployment "dev-2" {
  inputs = {
    aws_region         = "us-east-1"
    environment        = "dev-2"
    bucket_purpose     = "assets"
    force_destroy      = true
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "expire-dev-assets"
        enabled = true
        expiration = {
          days = 45
        }
      }
    ]

    tags = {
      CostCenter = "sandbox"
      Owner      = "frontend-team"
      Tier       = "dev"
    }
  }
}

deployment "dev-3" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "dev-3"
    bucket_purpose     = "reports"
    force_destroy      = true
    versioning_enabled = false
    bucket_key_enabled = false

    lifecycle_rules = [
      {
        id      = "expire-dev-reports"
        enabled = true
        expiration = {
          days = 14
        }
      }
    ]

    tags = {
      CostCenter = "sandbox"
      Owner      = "analytics-team"
      Tier       = "dev"
    }
  }
}

deployment "staging-1" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "staging-1"
    bucket_purpose     = "app-logs"
    force_destroy      = true
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "transition-staging-logs"
        enabled = true
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
        expiration = {
          days = 180
        }
      }
    ]

    tags = {
      CostCenter = "preprod"
      Owner      = "platform-team"
      Tier       = "staging"
    }
  }
}

deployment "staging-2" {
  inputs = {
    aws_region         = "us-east-1"
    environment        = "staging-2"
    bucket_purpose     = "assets"
    force_destroy      = true
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "transition-staging-assets"
        enabled = true
        transition = [
          {
            days          = 60
            storage_class = "STANDARD_IA"
          }
        ]
      }
    ]

    tags = {
      CostCenter = "preprod"
      Owner      = "frontend-team"
      Tier       = "staging"
    }
  }
}

deployment "staging-3" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "staging-3"
    bucket_purpose     = "reports"
    force_destroy      = true
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "expire-staging-reports"
        enabled = true
        expiration = {
          days = 365
        }
      }
    ]

    tags = {
      CostCenter = "preprod"
      Owner      = "analytics-team"
      Tier       = "staging"
    }
  }
}

deployment "prod-1" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "prod-1"
    bucket_purpose     = "app-logs"
    force_destroy      = false
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "archive-prod-logs"
        enabled = true
        transition = [
          {
            days          = 90
            storage_class = "GLACIER_IR"
          }
        ]
      }
    ]

    tags = {
      CostCenter = "production"
      Owner      = "platform-team"
      Tier       = "prod"
    }
  }
}

deployment "prod-2" {
  inputs = {
    aws_region         = "us-east-1"
    environment        = "prod-2"
    bucket_purpose     = "assets"
    force_destroy      = false
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "archive-prod-assets"
        enabled = true
        transition = [
          {
            days          = 180
            storage_class = "GLACIER_IR"
          }
        ]
      }
    ]

    tags = {
      CostCenter = "production"
      Owner      = "frontend-team"
      Tier       = "prod"
    }
  }
}

deployment "prod-3" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "prod-3"
    bucket_purpose     = "reports"
    force_destroy      = false
    versioning_enabled = true
    bucket_key_enabled = true

    lifecycle_rules = [
      {
        id      = "retain-prod-reports"
        enabled = true
        transition = [
          {
            days          = 365
            storage_class = "DEEP_ARCHIVE"
          }
        ]
      }
    ]

    tags = {
      CostCenter = "production"
      Owner      = "analytics-team"
      Tier       = "prod"
    }
  }
}
