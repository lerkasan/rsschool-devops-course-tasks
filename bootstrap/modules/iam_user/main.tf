resource "aws_iam_user" "this" {
  #checkov:skip=CKV_AWS_273:The task #1 specifies that a new IAM user should be created.

  name = var.user_name
  permissions_boundary = aws_iam_policy.this.arn
  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name        = join("-", [var.user_name, "permission_boundaries_policy"])
  policy = data.aws_iam_policy_document.permission_boundaries.json
  tags = var.tags
}

resource "aws_iam_user_group_membership" "this" {
  user = aws_iam_user.this.name
  groups = var.group_names
}