locals {
  ami_architecture = var.ami_architectures[var.os_architecture]
  ami_owner_id     = var.ami_owner_ids[var.os]
  ami_name         = local.ubuntu_ami_name_filter
  ubuntu_ami_name_filter = format("%s/images/%s-ssd/%s-%s-%s-%s-%s-*", var.os, var.ami_virtualization, var.os,
  var.os_releases[var.os_version], var.os_version, var.os_architecture, var.os_product)
  ssh_port = 22
}