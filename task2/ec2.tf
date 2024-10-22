resource "aws_instance" "appserver" {
  availability_zone           = local.availability_zones[0]
  subnet_id                   = module.private_subnet[var.private_subnets[0]].id
  associate_public_ip_address = false
  ami                         = data.aws_ami.this.id
  instance_type               = var.ec2_instance_type
  user_data                   = data.cloudinit_config.user_data.rendered
  key_name                    = var.appserver_private_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.appserver.id]
  monitoring                  = true

  tags = {
    Name        = "demo_appserver"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_instance" "bastion" {
  availability_zone           = local.availability_zones[0]
  subnet_id                   = module.public_subnet[var.public_subnets[0]].id
  associate_public_ip_address = true
  ami                         = data.aws_ami.this.id
  instance_type               = var.bastion_instance_type
  user_data                   = data.cloudinit_config.user_data.rendered
  key_name                    = var.bastion_private_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  monitoring                  = true

  tags = {
    Name        = "demo_bastion"
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}