resource "aws_iam_group" "this" {
  name = var.group_name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "this" {
  #checkov:skip=CKV2_AWS_56:The task #1 specifies that a new user should have IAMFullAccess policy attached, which in general is not recommended for security reasons.

  for_each = var.aws_managed_policies

  group      = aws_iam_group.this.name
  policy_arn = data.aws_iam_policy.this[each.key].arn
}

resource "aws_iam_policy" "enforce_MFA" {
  name   = join("-", [var.group_name, "enforce_mfa"])
  policy = data.aws_iam_policy_document.enforce_MFA.json
}

resource "aws_iam_group_policy_attachment" "enforce_MFA" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.enforce_MFA.arn
}