locals {
  env_name                   = "${lower(var.project_name)}-${var.environment}"
  github_actions_policy_name = "${var.github_actions_role}Policy"
}