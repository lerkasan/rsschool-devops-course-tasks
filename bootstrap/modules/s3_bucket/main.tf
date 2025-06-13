resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_status == "Enabled" ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.versioning_status == "Enabled" ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "${var.bucket_name}-s3-lifecycle-rule"
    status = var.lifecycle_rule.status

    filter {
      prefix = var.lifecycle_rule.prefix
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_rule.noncurrent_version_expiration_days
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_rule.noncurrent_version_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_rule.noncurrent_version_transition_days * 2
      storage_class   = "GLACIER"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 10
    }
  }

  # Bucket versioning must be enabled first
  depends_on = [aws_s3_bucket_versioning.this[0]]
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}