data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "permission_boundaries" {

  statement {
    sid    = "ServiceBoundaries"
    effect = "Allow"
    actions = [ for action in var.permission_boundaries_allow : action ]
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
