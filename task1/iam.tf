data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    effect    = "Allow"
    actions   = var.github_actions_role_permissions
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  name               = var.github_actions_role
  assume_role_policy = data.aws_iam_policy_document.oidc.json
}

resource "aws_iam_policy" "this" {
  name   = local.github_actions_policy_name
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# data "aws_iam_policy" "AmazonVPCFullAccess" {
#   arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "vpc_full_access" {
#   role       = aws_iam_role.this.name
#   policy_arn = data.aws_iam_policy.AmazonVPCFullAccess.arn
# }