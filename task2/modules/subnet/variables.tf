variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "vpc_id" {
  description   = "VPC id"
  type          = string
}

variable "route_table_id" {
  description   = "route_table_id"
  type          = string
}

variable "az" {
  description   = "Availability zone"
  type          = string
}

variable "is_public" {
  description   = "Toggle to set a subnet to be public/private"
  type          = bool
  default       = false
}

variable "project_name" {
  description   = "Project name"
  type          = string
  default       = "demo"
}

variable "environment" {
  description   = "Environment: dev/stage/prod"
  type          = string
  default       = "stage"
}