data "tls_certificate" "github_actions" {
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
# https://github.blog/changelog/2023-07-13-github-actions-oidc-integration-with-aws-no-longer-requires-pinning-of-intermediate-tls-certificates/
# https://stackoverflow.com/a/76603055
  url = "${local.oidc_github_actions.provider_url}/.well-known/openid-configuration"
}

data "aws_iam_policy" "this" {
  for_each = var.aws_managed_policies

  arn = join("/", ["arn:aws:iam::aws:policy", each.key])
}

data "aws_iam_policy_document" "permission_boundaries" {
  #checkov:skip=CKV_AWS_107:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_109:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_111:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_356:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV2_AWS_40:The task #1 specifies that a new role should have IAMFullAccess policy attached, which in general is not recommended for security reasons.

  statement {
    sid    = "ServiceBoundaries"
    effect = "Allow"
    actions = var.permission_boundaries_allow
    resources = ["*"]
  }
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-wif
data "aws_iam_policy_document" "oidc" {
  #checkov:skip=CKV_AWS_358:False positive for: "Ensure AWS GitHub Actions OIDC authorization policies only allow safe claims and claim order"

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${local.oidc_github_actions.domain_name}:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_repo}:*"]
      variable = "${local.oidc_github_actions.domain_name}:sub"
    }
  }
}
