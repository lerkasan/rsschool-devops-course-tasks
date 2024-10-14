resource "aws_security_group" "appserver" {
  name        = "appserver_security_group"
  description = "Demo security group for application server"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name        = "demo_appserver_sg"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion_security_group"
  description = "Demo security group for bastion"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name        = "demo_bastion_sg"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group_rule" "appserver_allow_inbound_ssh_from_bastion" {
  type                     = "ingress"
  description              = "SSH ingress"
  from_port                = var.ssh_port
  to_port                  = var.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "bastion_allow_inbound_ssh_from_admin_ip" {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = [format("%s/%s", local.admin_public_ip, 32)]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_allow_outbound_ssh_to_appserver" {
  type                     = "egress"
  description              = "SSH egress"
  from_port                = var.ssh_port
  to_port                  = var.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.bastion.id
}