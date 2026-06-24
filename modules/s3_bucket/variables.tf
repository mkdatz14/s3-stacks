variable "project" {
  description = "Project identifier used for naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment name, such as dev-1, staging-2, or prod-3."
  type        = string
}

variable "bucket_purpose" {
  description = "Short purpose label used in the generated bucket name and tags."
  type        = string
}

variable "bucket_name_override" {
  description = "Optional explicit bucket name. Leave empty to generate a unique name."
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Whether Terraform can delete the bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether S3 object versioning is enabled."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm for bucket objects."
  type        = string
  default     = "AES256"
}

variable "bucket_key_enabled" {
  description = "Whether S3 bucket keys are enabled for server-side encryption."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules passed to the S3 bucket module."
  type        = any
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
