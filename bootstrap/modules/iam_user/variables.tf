variable "user_name" {
  description = "Name for IAM user"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.user_name))
    error_message = "User name must have lowercase letters, numbers, and hyphens only)."
  }
}

variable "permission_boundaries_allow" {
  description = "Set of permission boundaries for IAM user"
  type        = set(string)
  default     = []
}

variable "aws_managed_policies" {
  description = "Set of AWS managed policies to attach to IAM user"
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags for IAM user"
  type        = map(string)
  default     = {}
}