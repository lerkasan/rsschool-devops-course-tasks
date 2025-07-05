module "vpc" {
  for_each = { for vpc in var.vpcs : vpc.cidr_block => vpc }

  source = "./modules/vpc"

  vpc_name                 = each.value.name
  cidr_block               = each.value.cidr_block
  public_subnets           = each.value.public_subnets
  private_subnets          = each.value.private_subnets ### TODO: Currently we are attaching  NAT gateways to all private subnets. Should we allow users to specify which private subnets should have NAT gateways?
  enable_dns_hostnames     = each.value.enable_dns_hostnames
  enable_dns_support       = each.value.enable_dns_support
  enable_flow_logs         = each.value.enable_flow_logs
  flow_logs_retention_days = each.value.flow_logs_retention_days ### TODO: What if enable_flow_logs is false? Should we set flow_logs_retention_days to a value or not include it at all?
  # admin_public_ips         = var.admin_public_ips   ### Needed for NACL rules to allow SSH access from admin public IPs. Commented out because NACL are commented out in the nacl.tf
  tags = each.value.tags
}

module "ec2_instance_connect_endpoint" {
  for_each = { for endpoint in var.ec2_instance_connect_endpoints : endpoint.vpc_cidr => endpoint }

  source = "./modules/ec2_instance_connect_endpoint"

  vpc_id           = module.vpc[each.key].vpc_id
  subnet_id        = module.vpc[each.key].subnets[each.value.subnet_cidr].id
  admin_public_ips = var.admin_public_ips
  tags             = each.value.tags
}

module "bastion" {
  for_each = { for ec2 in var.ec2_bastions : coalesce(ec2.tags["Name"], "noname") => ec2 }

  source = "./modules/ec2"

  ec2_instance_type                      = each.value.ec2_instance_type
  vpc_id                                 = module.vpc[each.value.vpc_cidr].vpc_id
  subnet_id                              = module.vpc[each.value.vpc_cidr].subnets[each.value.subnet_cidr].id
  private_ip                             = each.value.private_ip
  associate_public_ip_address            = each.value.associate_public_ip_address
  volume_type                            = each.value.volume_type
  volume_size                            = each.value.volume_size
  delete_on_termination                  = each.value.delete_on_termination
  private_ssh_key_name                   = each.value.private_ssh_key_name
  admin_public_ssh_key_names             = each.value.admin_public_ssh_key_names
  admin_public_ips                       = var.admin_public_ips
  enable_ec2_instance_connect_endpoint   = each.value.enable_ec2_instance_connect_endpoint
  ec2_connect_endpoint_security_group_id = module.ec2_instance_connect_endpoint[each.value.vpc_cidr].security_group_id
  os                                     = each.value.os
  os_product                             = each.value.os_product
  os_architecture                        = each.value.os_architecture
  os_version                             = each.value.os_version
  os_releases                            = each.value.os_releases
  ami_virtualization                     = each.value.ami_virtualization
  ami_architectures                      = each.value.ami_architectures
  ami_owner_ids                          = each.value.ami_owner_ids
  userdata                               = data.cloudinit_config.userdata_bastion[each.key].rendered
  userdata_config                        = each.value.userdata_config
  tags                                   = each.value.tags
}

module "k3s_master" {
  for_each = { for ec2 in var.ec2_k3s_masters : coalesce(ec2.tags["Name"], "noname") => ec2 }

  source = "./modules/ec2"

  ec2_instance_type                      = each.value.ec2_instance_type
  vpc_id                                 = module.vpc[each.value.vpc_cidr].vpc_id
  subnet_id                              = module.vpc[each.value.vpc_cidr].subnets[each.value.subnet_cidr].id
  private_ip                             = each.value.private_ip
  associate_public_ip_address            = each.value.associate_public_ip_address
  volume_type                            = each.value.volume_type
  volume_size                            = each.value.volume_size
  delete_on_termination                  = each.value.delete_on_termination
  private_ssh_key_name                   = each.value.private_ssh_key_name
  admin_public_ssh_key_names             = each.value.admin_public_ssh_key_names
  enable_bastion_access                  = each.value.enable_bastion_access
  bastion_security_group_id              = module.bastion[each.value.bastion_name].security_group_id
  enable_ec2_instance_connect_endpoint   = each.value.enable_ec2_instance_connect_endpoint
  ec2_connect_endpoint_security_group_id = module.ec2_instance_connect_endpoint[each.value.vpc_cidr].security_group_id
  os                                     = each.value.os
  os_product                             = each.value.os_product
  os_architecture                        = each.value.os_architecture
  os_version                             = each.value.os_version
  os_releases                            = each.value.os_releases
  ami_virtualization                     = each.value.ami_virtualization
  ami_architectures                      = each.value.ami_architectures
  ami_owner_ids                          = each.value.ami_owner_ids
  userdata                               = data.cloudinit_config.userdata_k3s[each.key].rendered
  userdata_config                        = each.value.userdata_config
  iam_policy_statements                  = each.value.iam_policy_statements
  tags                                   = each.value.tags
}


module "k3s_agent" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  source = "./modules/ec2"

  ec2_instance_type                      = each.value.ec2_instance_type
  vpc_id                                 = module.vpc[each.value.vpc_cidr].vpc_id
  subnet_id                              = module.vpc[each.value.vpc_cidr].subnets[each.value.subnet_cidr].id
  private_ip                             = each.value.private_ip
  associate_public_ip_address            = each.value.associate_public_ip_address
  volume_type                            = each.value.volume_type
  volume_size                            = each.value.volume_size
  delete_on_termination                  = each.value.delete_on_termination
  private_ssh_key_name                   = each.value.private_ssh_key_name
  admin_public_ssh_key_names             = each.value.admin_public_ssh_key_names
  enable_bastion_access                  = each.value.enable_bastion_access
  bastion_security_group_id              = module.bastion[each.value.bastion_name].security_group_id
  enable_ec2_instance_connect_endpoint   = each.value.enable_ec2_instance_connect_endpoint
  ec2_connect_endpoint_security_group_id = module.ec2_instance_connect_endpoint[each.value.vpc_cidr].security_group_id
  os                                     = each.value.os
  os_product                             = each.value.os_product
  os_architecture                        = each.value.os_architecture
  os_version                             = each.value.os_version
  os_releases                            = each.value.os_releases
  ami_virtualization                     = each.value.ami_virtualization
  ami_architectures                      = each.value.ami_architectures
  ami_owner_ids                          = each.value.ami_owner_ids
  userdata                               = data.cloudinit_config.userdata_k3s[each.key].rendered
  userdata_config                        = each.value.userdata_config
  iam_policy_statements                  = each.value.iam_policy_statements
  tags                                   = each.value.tags

  depends_on = [module.k3s_master]
}

resource "aws_route53_record" "jenkins" {
  count = var.domain_name != null ? 0 : 1

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = "jenkins.${data.aws_route53_zone.this[0].name}"
  type    = "A"
  ttl     = 300
  records = [module.bastion["BastionHost"].public_ip]

  lifecycle {
    ignore_changes = [
      zone_id,
      multivalue_answer_routing_policy,
      records,
      ttl
    ]
  }
}