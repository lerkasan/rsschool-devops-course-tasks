data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_repo}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}
