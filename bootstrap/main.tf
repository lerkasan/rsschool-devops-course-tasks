module "s3_bucket" {
  for_each = { for bucket in var.s3_buckets : bucket.name => bucket }

  source = "./modules/s3_bucket"

  bucket_name       = each.value.name
  enable_encryption = each.value.enable_encryption
  versioning_status = each.value.versioning_status
  lifecycle_rule    = each.value.lifecycle_rule
}

module "iam_user" {
  for_each = { for user in var.users : user.name => user }

  source = "./modules/iam_user"

  user_name                   = each.value.name
  permission_boundaries_allow = each.value.permission_boundaries_allow
  aws_managed_policies        = each.value.aws_managed_policies
  tags                        = each.value.tags
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