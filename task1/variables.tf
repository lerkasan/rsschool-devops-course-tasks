variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Project tags"
  type        = map(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name for project tfstate"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository for OIDC configuration"
  type        = string
}

variable "github_actions_role_name" {
  description = "Name for GitHub Actions role"
  type        = string
}

variable "github_actions_role_permissions" {
  description = "List of permissions for Github Actions role"
  type        = set(string)
}