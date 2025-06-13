
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "users" {
  type = set(object({
    name                        = string
    aws_managed_policies        = set(string)
    permission_boundaries_allow = set(string)
    tags                        = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for user in var.users : can(regex("^[a-zA-Z0-9-]+$", user.name))
    ])
    error_message = "User name must have letters, numbers, and hyphens only)."
  }
}


variable "oidc_roles" {
  type = set(object({
    name                        = string
    github_repo                 = string
    aws_managed_policies        = set(string)
    permission_boundaries_allow = set(string)
    tags                        = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for role in var.oidc_roles : can(regex("^[a-zA-Z0-9-]+$", role.name))
    ])
    error_message = "Role name must have letters, numbers, and hyphens only)."
  }
}

variable "s3_buckets" {
  type = list(object({
    name              = string
    region            = optional(string)
    enable_encryption = optional(bool, true)
    versioning_status = optional(string, "Enabled")
    lifecycle_rule = optional(object({
      status                             = optional(string, "Enabled")
      prefix                             = optional(string, "")
      expiration_days                    = optional(number, 0)
      noncurrent_version_expiration_days = optional(number, 90)
      noncurrent_version_transition_days = optional(number, 30)
    }))
    tags = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for bucket in var.s3_buckets : can(regex("^[a-z0-9-]+$", bucket.name))
    ])
    error_message = "S3 bucket name must be a valid DNS-compliant name."
  }

  validation {
    condition = alltrue([
      for bucket in var.s3_buckets : contains(["Enabled", "Suspended", "Disabled"], bucket.versioning_status)
    ])
    error_message = "Valid values for s3_bucket.versioning_status are Enabled, Suspended, Disabled"
  }

  default = []
}