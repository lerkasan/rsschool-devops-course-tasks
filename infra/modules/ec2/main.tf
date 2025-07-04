#trivy:ignore:AVD-AWS-0131  # TODO: Add KMS key, add permissions for the user to access KMS key, and then encrypt root EBS volume
resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.private_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.ec2_instance.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data                   = var.userdata != null ? var.userdata : data.cloudinit_config.user_data.rendered
  ebs_optimized               = true
  monitoring                  = true

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    # encrypted             = true  # TODO: Add KMS key, add permissions for the user to access KMS key, and then encrypt root EBS volume
    delete_on_termination = var.delete_on_termination
  }

  metadata_options {
    http_tokens = "required"
  }

  # To ignore changes to the AMI ID, which can happen when the AMI is updated in AWS. Those changes can cause the instance to be recreated, which is not always desired.
  # https://discuss.hashicorp.com/t/handle-changed-image-ami-on-aws/28652
  lifecycle {
    ignore_changes = [ami]
  }

  tags = var.tags
}

resource "aws_iam_instance_profile" "this" {
  name = join("_", [coalesce(var.tags["Name"], "noname"), "iam-profile"])
  role = aws_iam_role.this.name

  tags = merge(var.tags, {
    Name = join("_", [coalesce(var.tags["Name"], "noname"), "iam-profile"])
  })
}

resource "aws_iam_role" "this" {
  name               = join("_", [coalesce(var.tags["Name"], "noname"), "iam-role"])
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = join("_", [coalesce(var.tags["Name"], "noname"), "iam-role"])
  })
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  count = var.enable_ec2_instance_connect_endpoint ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "this" {
  for_each = var.iam_policy_statements != null ? { for statement in var.iam_policy_statements : statement.sid => statement } : {}

  name        = join("_", [each.key, "iam-policy"])
  description = "IAM policy for EC2 instance - ${each.key}"
  policy      = data.aws_iam_policy_document.this[each.key].json

  tags = merge(var.tags, {
    Name = "${each.key}_iam-policy"
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.iam_policy_statements != null ? { for statement in var.iam_policy_statements : statement.sid => statement } : {}

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[each.key].arn
}