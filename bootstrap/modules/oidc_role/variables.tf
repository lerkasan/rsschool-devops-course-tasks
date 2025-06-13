variable "role_name" {
  description = "Name for IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.role_name))
    error_message = "Role name must have letters, numbers, and hyphens only)."
  }
}

variable "permission_boundaries_allow" {
  description = "Set of permission boundaries for IAM role"
  type        = set(string)
  default     = []
}

variable "aws_managed_policies" {
  description = "Set of AWS managed policies to attach to IAM role"
  type        = set(string)
  default     = []
}

variable "github_repo" {
  description = "GitHub repository for OIDC configuration"
  type        = string
}

variable "tags" {
  description = "Tags for IAM role"
  type        = map(string)
  default     = {}
}