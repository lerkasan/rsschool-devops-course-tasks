data "aws_iam_policy_document" "permission_boundaries" {
  #checkov:skip=CKV_AWS_107:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_109:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_111:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV_AWS_356:Wildcard resources are used for definition of permission boundaries.
  #checkov:skip=CKV2_AWS_40:The task #1 specifies that a new user should have IAMFullAccess policy attached, which in general is not recommended for security reasons.

  statement {
    sid    = "ServiceBoundaries"
    effect = "Allow"
    actions = var.permission_boundaries_allow
    resources = ["*"]
  }
}