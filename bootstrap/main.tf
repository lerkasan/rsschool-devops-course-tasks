module "s3_bucket" {
  for_each = { for bucket in var.s3_buckets : bucket.name => bucket }

  source = "./modules/s3_bucket"

  bucket_name         = each.value.name
  enable_encryption   = each.value.enable_encryption
  enable_logging      = each.value.enable_logging
  logging_bucket_name = each.value.logging_bucket_name
  versioning_status   = each.value.versioning_status
  lifecycle_rule      = each.value.lifecycle_rule
}

module "iam_group" {
  for_each = { for group in var.groups : group.name => group }

  source = "./modules/iam_group"

  group_name           = each.value.name
  path                 = each.value.path
  aws_managed_policies = each.value.aws_managed_policies
}

module "iam_user" {
  for_each = { for user in var.users : user.name => user }

  source = "./modules/iam_user"

  user_name                   = each.value.name
  group_names                 = each.value.group_names
  permission_boundaries_allow = each.value.permission_boundaries_allow
  tags                        = each.value.tags

  depends_on = [module.iam_group]
}

module "oidc_role" {
  for_each = { for role in var.oidc_roles : role.name => role }

  source = "./modules/oidc_role"

  role_name                   = each.value.name
  github_repo                 = each.value.github_repo
  permission_boundaries_allow = each.value.permission_boundaries_allow
  aws_managed_policies        = each.value.aws_managed_policies
  tags                        = each.value.tags
}