locals {
  availability_zones = [for az_letter in var.az_letters : format("%s%s", var.aws_region, az_letter)]
}