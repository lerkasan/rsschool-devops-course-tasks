# This file defines the Network ACLs (NACLs) for the VPC.
# Currently, it is commented out as further debugging and troubleshooting is needed to ensure the rules are correctly applied.
# NACLs rules for SSH traffic seem to work, but the rules for HTTP and HTTPS traffic are not functioning as expected. 
# If this file is uncommented, then the bastion hosts and appservers can be reached via SSH. You would be able to SSH into the bastion host and then from there SSH into the appservers.
# You also would be able to have HTTP/HTTPS traffic come to the bastion host and curl different websites from the bastion host.
# However, the HTTP/HTTPS traffic to the appservers is not working.
# ICMP traffic is also not working, so you would not be able to ping the bastion host or appservers.

# resource "aws_default_network_acl" "this" {
#   default_network_acl_id = aws_vpc.this.default_network_acl_id
#   # no rules defined, deny all traffic in this ACL
# }

# resource "aws_network_acl" "public" {
#   # checkov:skip=CKV2_AWS_1:False Positive. This NACL is attached to subnets. 
#   vpc_id     = aws_vpc.this.id
#   subnet_ids = [for subnet in aws_subnet.public : subnet.id]

#   tags = merge(var.tags, {
#     Name = "${var.vpc_name}_public-subnet-nacl"
#   })
# }

# resource "aws_network_acl" "private" {
#   # checkov:skip=CKV2_AWS_1:False Positive. This NACL is attached to subnets. 
#   vpc_id     = aws_vpc.this.id
#   subnet_ids = [for subnet in aws_subnet.private : subnet.id]

#   tags = merge(var.tags, {
#     Name = "${var.vpc_name}_private-subnet-nacl"
#   })
# }

# resource "aws_network_acl_rule" "allow_inbound_ssh_to_public_subnets_from_admin_ip" {
#   for_each = var.admin_public_ips != null ? toset(var.admin_public_ips) : toset([])

#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 200 + index(var.admin_public_ips, each.value)
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = format("%s/%s", each.value, 32)
#   from_port      = local.ssh_port
#   to_port        = local.ssh_port
# }

# resource "aws_network_acl_rule" "allow_outbound_ssh_response_from_public_subnets_to_admin_ip" {
#   for_each = var.admin_public_ips != null ? toset(var.admin_public_ips) : toset([])

#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 200 + index(var.admin_public_ips, each.value)
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = format("%s/%s", each.value, 32)
#   from_port      = local.port_range_unprivileged_start
#   to_port        = local.port_range_end
# }



# resource "aws_network_acl_rule" "allow_inbound_ssh_to_private_subnets_from_vpc_cidr" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 250
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.this.cidr_block
#   from_port      = local.ssh_port
#   to_port        = local.ssh_port
# }

# resource "aws_network_acl_rule" "allow_outbound_ssh_response_from_private_subnets_to_vpc_cidr" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 260
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.this.cidr_block
#   from_port      = local.port_range_unprivileged_start
#   to_port        = local.port_range_end
# }


# resource "aws_network_acl_rule" "allow_outbound_ssh_from_public_subnets_to_vpc_cidr" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 270
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.this.cidr_block
#   from_port      = local.ssh_port
#   to_port        = local.ssh_port
# }

# resource "aws_network_acl_rule" "allow_inbound_ssh_response_from_private_subnets_to_vpc_cidr" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 280
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.this.cidr_block
#   from_port      = local.port_range_unprivileged_start
#   to_port        = local.port_range_end
# }




# resource "aws_network_acl_rule" "allow_outbound_http_from_public_subnets_to_any" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 300
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.http_port
#   to_port        = local.http_port
# }

# resource "aws_network_acl_rule" "allow_outbound_https_from_public_subnets_to_any" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 310
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.https_port
#   to_port        = local.https_port
# }

# #tfsec:ignore:aws-ec2-no-public-ingress-acl
# resource "aws_network_acl_rule" "allow_inbound_http_and_https_responses_to_public_subnets_from_any" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 320
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_middle
#   to_port        = local.port_range_end
# }


# resource "aws_network_acl_rule" "allow_outbound_http_from_private_subnets_to_any" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 330
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.http_port
#   to_port        = local.http_port
# }

# resource "aws_network_acl_rule" "allow_outbound_https_from_private_subnets_to_any" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 340
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.https_port
#   to_port        = local.https_port
# }

# #tfsec:ignore:aws-ec2-no-public-ingress-acl
# resource "aws_network_acl_rule" "allow_inbound_http_and_https_responses_to_private_subnets_from_any" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 350
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_middle
#   to_port        = local.port_range_end
# }

# resource "aws_network_acl_rule" "allow_outbound_icmp_from_public_subnets_to_any" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 360
#   egress         = true
#   protocol       = "icmp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_start
#   to_port        = local.port_range_end
# }

# resource "aws_network_acl_rule" "allow_outbound_icmp_from_private_subnets_to_any" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 370
#   egress         = true
#   protocol       = "icmp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_start
#   to_port        = local.port_range_end
# }

# resource "aws_network_acl_rule" "allow_inbound_icmp_to_public_subnets_from_any" {
#   network_acl_id = aws_network_acl.public.id
#   rule_number    = 380
#   egress         = false
#   protocol       = "icmp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_start
#   to_port        = local.port_range_end
# }

# resource "aws_network_acl_rule" "allow_inbound_icmp_to_private_subnets_from_any" {
#   network_acl_id = aws_network_acl.private.id
#   rule_number    = 390
#   egress         = false
#   protocol       = "icmp"
#   rule_action    = "allow"
#   cidr_block     = local.anywhere
#   from_port      = local.port_range_start
#   to_port        = local.port_range_end
# }
