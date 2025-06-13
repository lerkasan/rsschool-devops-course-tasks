data "aws_iam_policy_document" "permission_boundaries" {

  statement {
    sid    = "ServiceBoundaries"
    effect = "Allow"
    actions = [ for action in var.permission_boundaries_allow : action ]
    resources = ["*"]
  }
}