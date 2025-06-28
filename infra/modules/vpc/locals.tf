locals {
  # Needed for NACL rules. Commented out because NACL are commented out in the nacl.tf
  # anywhere                      = "0.0.0.0/0"
  # ssh_port                      = 22
  # http_port                     = 80
  # https_port                    = 443
  # port_range_start              = 0
  # port_range_unprivileged_start = 1024
  # port_range_middle             = 32768
  # port_range_end                = 65535
  iam_user_arn_parts = split("/", data.aws_caller_identity.current.arn)
  iam_username       = element(local.iam_user_arn_parts, length(local.iam_user_arn_parts) - 1)
}