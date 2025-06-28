resource "aws_kms_key" "this" {
  # checkov:skip=CKV2_AWS_64:False Positive. The KMS key policy is actually created via "aws_kms_key_policy" resource.

  count = var.enable_encryption ? 1 : 0

  description         = "KMS key for S3 encryption"
  enable_key_rotation = true

  tags = merge(var.tags, {
    Name = "${var.bucket_name}-bucket-encrypt-key"
  })
}

resource "aws_kms_alias" "this" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${var.bucket_name}-bucket-encrypt-key"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this[0].arn
    }
  }
}

resource "aws_kms_key_policy" "this" {
  count = var.enable_encryption ? 1 : 0

  key_id = aws_kms_key.this[0].id
  policy = jsonencode({
    Id = "${var.bucket_name}-encrypt-key-policy"
    Statement = [
      {
        Sid    = "Enable IAM Permissions for Root User"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = aws_kms_key.this[0].arn
      },
      # {
      #   Sid    = "Allow administration of the key"
      #   Effect = "Allow"
      #   Principal = {
      #     AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${local.iam_username}"  # local.iam_username would not work with the OIDC role in Github Actions
      #   },
      #   Action = [
      #     "kms:ReplicateKey",
      #     "kms:Create*",
      #     "kms:Describe*",
      #     "kms:Enable*",
      #     "kms:List*",
      #     "kms:Put*",
      #     "kms:Update*",
      #     "kms:Revoke*",
      #     "kms:Disable*",
      #     "kms:Get*",
      #     "kms:Delete*",
      #     "kms:ScheduleKeyDeletion",
      #     "kms:CancelKeyDeletion"
      #   ],
      #   Resource = aws_kms_key.this[0].arn
      # }
    ]
    Version = "2012-10-17"
  })
}
