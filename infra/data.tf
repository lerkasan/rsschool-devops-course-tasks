data "aws_region" "current" {}

# ------------------- User data for cloud-init --------------------------
# User-data can be found in /var/lib/cloud/instance/user-data.txt.i on an AWS EC2 running Ubuntu.
data "cloudinit_config" "userdata_k3s" {
  for_each = { for ec2 in setunion(var.ec2_k3s_masters, var.ec2_k3s_agents) : coalesce(ec2.tags["Name"], "noname") => ec2 }

  base64_encode = true
  gzip          = true

  dynamic "part" {
    for_each = each.value.userdata_config != null ? [1] : []

    content {
      content_type = "text/cloud-config"
      content = yamlencode({
        "write_files" = [
          {
            "path"        = "/tmp/install_k3s_master.sh"
            "permissions" = "0700"
            "owner"       = "root:root"
            "content" = templatefile("${path.root}/templates/k3s/install_k3s_master_sh.tftpl", {
              region                        = data.aws_region.current.name,
              hostname_ssm_parameter_name   = each.value.userdata_config.hostname_ssm_parameter_name,
              token_ssm_parameter_name      = each.value.userdata_config.token_ssm_parameter_name,
              kubeconfig_ssm_parameter_name = can(each.value.userdata_config.kubeconfig_ssm_parameter_name) ? each.value.userdata_config.kubeconfig_ssm_parameter_name : null
            })
          },
          {
            "path"        = "/tmp/install_k3s_agent.sh"
            "permissions" = "0700"
            "owner"       = "root:root"
            "content" = templatefile("${path.root}/templates/k3s/install_k3s_agent_sh.tftpl", {
              region                      = data.aws_region.current.name,
              hostname_ssm_parameter_name = each.value.userdata_config.hostname_ssm_parameter_name,
              token_ssm_parameter_name    = each.value.userdata_config.token_ssm_parameter_name,
            })
          }
        ]
        }
      )
    }
  }

  dynamic "part" {
    for_each = each.value.userdata_config != null ? [1] : []

    content {
      content_type = "text/cloud-config"
      content = templatefile("${path.root}/templates/k3s/userdata.tftpl", {
        install_k3s_master = can(each.value.userdata_config.install_k3s_master) ? each.value.userdata_config.install_k3s_master : false,
        install_k3s_agent  = can(each.value.userdata_config.install_k3s_agent) ? each.value.userdata_config.install_k3s_agent : false,
      })
    }
  }
}

data "cloudinit_config" "userdata_bastion" {
  for_each = { for ec2 in var.ec2_bastions : coalesce(ec2.tags["Name"], "noname") => ec2 }

  base64_encode = true
  gzip          = true

# For debugging purposes to use the local_file resource to write the rendered userdata to a file.
  # base64_encode = false
  # gzip          = false


  dynamic "part" {
    for_each = each.value.userdata_config != null ? [1] : []

    content {
      content_type = "text/cloud-config"
      content = yamlencode({
        "write_files" = [
          {
            "path"        = "/tmp/add_kubeconfig.sh"
            "permissions" = "0700"
            "owner"       = "root:root"
            "content" = templatefile("${path.root}/templates/bastion/add_kubeconfig_sh.tftpl", {
              region                        = data.aws_region.current.name,
              hostname_ssm_parameter_name   = each.value.userdata_config.hostname_ssm_parameter_name,
              kubeconfig_ssm_parameter_name = each.value.userdata_config.kubeconfig_ssm_parameter_name
            })
          },
          {
            "path"        = "/tmp/configure_nginx.sh"
            "permissions" = "0700"
            "owner"       = "root:root"
            "content"     = file("${path.root}/templates/nginx/configure_nginx.sh")
          },          
          {
            "path"        = "/tmp/nginx_jenkins_config"
            "permissions" = "0640"
            "owner"       = "nginx:nginx"
            "content" = templatefile("${path.root}/templates/nginx/nginx_jenkins_config.tftpl", {
              domain_name          = "jenkins.${var.domain_name}",
              node_port            = local.node_port,
              k3s_agent_private_ip = var.ec2_k3s_agents[0].private_ip
              # k3s_agent_private_ip = module.k3s_agent["Worker-Node-1"].private_ip # Causes cycle. TODO: Find a way to loop over k3s agents to get their private IPs. 
            })
          }
        ]
        }
      )
    }
  }

  dynamic "part" {
    for_each = each.value.userdata_config != null ? [1] : []

    content {
      content_type = "text/cloud-config"
      content      = file("${path.root}/templates/bastion/userdata.tftpl")
    }
  }
}

data "aws_route53_zone" "this" {
  count = var.domain_name != null ? 0 : 1

  name         = var.domain_name
  private_zone = false
}

# For debugging purposes to use the local_file resource to write the rendered userdata to a file.
# resource "local_file" "test" {
#   filename = "${path.root}/test.txt"
#   content  = data.cloudinit_config.userdata_bastion["BastionHost"].rendered
# }