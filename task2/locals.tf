locals {
  availability_zones = [for az_letter in var.az_letters : format("%s%s", var.aws_region, az_letter)]
  admin_public_ip    = data.external.admin_public_ip.result["admin_public_ip"]
  ami_architecture   = var.ami_architectures[var.os_architecture]
  ami_owner_id       = var.ami_owner_ids[var.os]
  ami_name           = local.ubuntu_ami_name_filter
  ubuntu_ami_name_filter = format("%s/images/%s-ssd/%s-%s-%s-%s-%s-*", var.os, var.ami_virtualization, var.os,
  var.os_releases[var.os_version], var.os_version, var.os_architecture, var.os_product)
  http_port  = 80
  https_port = 443
}