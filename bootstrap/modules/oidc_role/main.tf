resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.oidc.json
  permissions_boundary = aws_iam_policy.this.arn
  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name        = join("-", [var.role_name, "permission_boundaries_policy"])
  policy = data.aws_iam_policy_document.permission_boundaries.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  #checkov:skip=CKV2_AWS_56:The task #1 specifies that a new role should have IAMFullAccess policy attached, which in general is not recommended for security reasons.

  for_each = var.aws_managed_policies

  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.this[each.key].arn
}