variable "user_name" {
  description = "Name for IAM user"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.user_name))
    error_message = "User name must have lowercase letters, numbers, and hyphens only)."
  }
}

variable "group_names" {
  description = "Set of IAM group names to add user to"
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for group in var.group_names : can(regex("^[a-zA-Z0-9-]+$", group))])
    error_message = "Group names must have letters, numbers, and hyphens only)."
  }
}

variable "permission_boundaries_allow" {
  description = "Set of permission boundaries for IAM user"
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags for IAM user"
  type        = map(string)
  default     = {}
}