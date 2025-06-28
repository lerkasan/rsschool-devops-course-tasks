resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = local.oidc_github_actions.provider_url
  client_id_list = [local.oidc_github_actions.audience_client_id]

  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  # https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  # https://github.blog/changelog/2023-07-13-github-actions-oidc-integration-with-aws-no-longer-requires-pinning-of-intermediate-tls-certificates/
  # https://stackoverflow.com/a/76603055
  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint,
    data.tls_certificate.github_actions.certificates[1].sha1_fingerprint,
    data.tls_certificate.github_actions.certificates[2].sha1_fingerprint
  ]
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.oidc.json
  permissions_boundary = aws_iam_policy.this.arn
  tags                 = var.tags
}

resource "aws_iam_policy" "this" {
  name   = join("-", [var.role_name, "permission_boundaries_policy"])
  policy = data.aws_iam_policy_document.permission_boundaries.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  #checkov:skip=CKV2_AWS_56:The task #1 specifies that a new role should have IAMFullAccess policy attached, which in general is not recommended for security reasons.

  for_each = var.aws_managed_policies

  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.this[each.key].arn
}