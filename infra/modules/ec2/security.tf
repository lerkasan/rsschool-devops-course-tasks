resource "aws_security_group" "ec2_instance" {
  name        = join("_", [coalesce(var.tags["Name"], "noname"), "security-group"])
  description = "security group for EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = join("_", [coalesce(var.tags["Name"], "noname"), "ec2-instance-sg"])
  })
}

resource "aws_security_group_rule" "allow_inbound_ssh_to_ec2_instance_from_admin_ip" {
  for_each = var.admin_public_ips != null ? toset(var.admin_public_ips) : toset([])

  type        = "ingress"
  description = "SSH ingress"
  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = "tcp"
  cidr_blocks = [format("%s/%s", each.value, 32)]
  security_group_id = aws_security_group.ec2_instance.id
}

resource "aws_security_group_rule" "allow_inbound_ssh_to_ec2_instance_from_bastion" {
  count = var.enable_bastion_access ? 1 : 0

  type                     = "ingress"
  description              = "SSH ingress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = var.bastion_security_group_id
  security_group_id        = aws_security_group.ec2_instance.id
}

resource "aws_security_group_rule" "allow_outbound_ssh_from_bastion_to_ec2_instance" {
  count = var.enable_bastion_access ? 1 : 0

  type                     = "egress"
  description              = "SSH egress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_instance.id
  security_group_id        = var.bastion_security_group_id
}

resource "aws_security_group_rule" "allow_inbound_ssh_to_ec2_instance_from_ec2_connect_endpoint" {
  count = var.enable_ec2_instance_connect_endpoint ? 1 : 0

  type                     = "ingress"
  description              = "SSH ingress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = var.ec2_connect_endpoint_security_group_id
  security_group_id        = aws_security_group.ec2_instance.id
}

resource "aws_security_group_rule" "allow_outbound_ssh_from_ec2_instance_to_ec2_connect_endpoint" {
  count = var.enable_ec2_instance_connect_endpoint ? 1 : 0

  type                     = "egress"
  description              = "SSH egress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_instance.id
  security_group_id        = var.ec2_connect_endpoint_security_group_id
}