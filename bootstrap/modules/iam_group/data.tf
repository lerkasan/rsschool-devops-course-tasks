data "aws_iam_policy" "this" {
  for_each = var.aws_managed_policies

  arn = join("/", ["arn:aws:iam::aws:policy", each.key])
}

data "aws_iam_policy_document" "enforce_MFA" {
  statement {
    sid    = "DenyAllIfMFANotEnabled"
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "Bool" # or maybe BoolIfExists?
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}