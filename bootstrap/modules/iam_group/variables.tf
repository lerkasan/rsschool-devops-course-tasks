variable "group_name" {
  description = "Name for IAM group"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.group_name))
    error_message = "Group name must have lowercase letters, numbers, and hyphens only)."
  }
}

variable "path" {
  description = "Path for IAM group"
  type        = string
  default     = "/"
}

variable "aws_managed_policies" {
  description = "Set of AWS managed policies to attach to IAM group"
  type        = set(string)
  default     = []
}