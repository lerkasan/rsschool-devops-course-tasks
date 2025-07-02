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
