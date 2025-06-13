resource "aws_iam_user" "this" {
  name = var.user_name
  permissions_boundary = aws_iam_policy.this.arn
  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name        = join("-", [var.user_name, "permission_boundaries_policy"])
  policy = data.aws_iam_policy_document.permission_boundaries.json
  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = var.aws_managed_policies

  user       = aws_iam_user.this.name
  policy_arn = join("/", ["arn:aws:iam::aws:policy", each.key])
}