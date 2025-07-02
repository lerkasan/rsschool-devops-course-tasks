resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_master_tcp_6443_from_bastion" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s API server ingress from bastion to k3s master"
  from_port                = local.k3s_api_port
  to_port                  = local.k3s_api_port
  protocol                 = "tcp"
  source_security_group_id = module.bastion["BastionHost"].security_group_id
  security_group_id        = module.k3s_master["Control-Plane"].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_master_tcp_6443_from_k3s_agents" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s API server ingress from k3s agents to k3s master"
  from_port                = local.k3s_api_port
  to_port                  = local.k3s_api_port
  protocol                 = "tcp"
  source_security_group_id = module.k3s_agent[each.key].security_group_id
  security_group_id        = module.k3s_master["Control-Plane"].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_master_tcp_10250_from_k3s_agents" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "kubelet metrics ingress from k3s agents to k3s master"
  from_port                = local.metrics_port
  to_port                  = local.metrics_port
  protocol                 = "tcp"
  source_security_group_id = module.k3s_agent[each.key].security_group_id
  security_group_id        = module.k3s_master["Control-Plane"].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_agents_tcp_10250_from_k3s_master" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "kubelet metrics ingress from k3s master to k3s agents"
  from_port                = local.metrics_port
  to_port                  = local.metrics_port
  protocol                 = "tcp"
  source_security_group_id = module.k3s_master["Control-Plane"].security_group_id
  security_group_id        = module.k3s_agent[each.key].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_master_udp_8472_from_k3s_agents" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s Flannel Vxlan ingress from k3s agents to k3s master"
  from_port                = local.flannel_vxlan_port
  to_port                  = local.flannel_vxlan_port
  protocol                 = "udp"
  source_security_group_id = module.k3s_agent[each.key].security_group_id
  security_group_id        = module.k3s_master["Control-Plane"].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_agents_udp_8472_from_k3s_master" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s Flannel Vxlan ingress from master to k3s agents"
  from_port                = local.flannel_vxlan_port
  to_port                  = local.flannel_vxlan_port
  protocol                 = "udp"
  source_security_group_id = module.k3s_master["Control-Plane"].security_group_id
  security_group_id        = module.k3s_agent[each.key].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_agents_udp_51820_from_k3s_master" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s Flannel Wireguard ingress from k3s master to k3s agents"
  from_port                = local.flannel_wireguard_port
  to_port                  = local.flannel_wireguard_port
  protocol                 = "udp"
  source_security_group_id = module.k3s_master["Control-Plane"].security_group_id
  security_group_id        = module.k3s_agent[each.key].security_group_id
}

resource "aws_security_group_rule" "allow_inbound_traffic_to_k3s_master_udp_51820_from_k3s_agents" {
  for_each = { for ec2 in var.ec2_k3s_agents : coalesce(ec2.tags["Name"], "noname") => ec2 }

  type                     = "ingress"
  description              = "k3s Flannel Wireguard ingress from k3s agents to k3s master"
  from_port                = local.flannel_wireguard_port
  to_port                  = local.flannel_wireguard_port
  protocol                 = "udp"
  source_security_group_id = module.k3s_agent[each.key].security_group_id
  security_group_id        = module.k3s_master["Control-Plane"].security_group_id
}
