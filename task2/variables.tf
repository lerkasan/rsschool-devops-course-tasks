variable "project_name" {
  description = "Project name"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment: dev/stage/prod"
  type        = string
  default     = "stage"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az_letters" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["a", "b"]
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.240.0/24", "10.0.250.0/24"]
}

# ---------------- EC2 parameters -----------

variable "appserver_private_ssh_key_name" {
  description = "Name of the SSH keypair to use with appserver"
  type        = string
  default     = "appserver_ssh_key_pair"
  sensitive   = true
}

variable "bastion_private_ssh_key_name" {
  description = "Name of the SSH keypair to use with bastion"
  type        = string
  default     = "bastion_ssh_key_pair"
  sensitive   = true
}

variable "admin_public_ssh_keys" {
  description = "List of names of the SSM parameters with admin public ssh keys"
  type        = list(string)
  default     = ["ssh_public_key"]
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "bastion_instance_type" {
  description = "AWS EC2 instance type for bastion"
  type        = string
  default     = "t2.micro"
}

# ---------------- OS parameters --------------------

variable "os" {
  description = "AMI OS"
  type        = string
  default     = "ubuntu"
}

variable "os_product" {
  description = "AMI OS product. Values: server or server-minimal"
  type        = string
  default     = "server"
}

variable "os_architecture" {
  description = "OS architecture"
  type        = string
  default     = "amd64"
}

variable "os_version" {
  description = "OS version"
  type        = string
  default     = "22.04"
}

variable "os_releases" {
  description = "OS release"
  type        = map(string)
  default = {
    "22.04" = "jammy"
  }
}

# ---------------- AMI filters ----------------------

variable "ami_virtualization" {
  description = "AMI virtualization type"
  type        = string
  default     = "hvm"
}

variable "ami_architectures" {
  description = "AMI architecture filters"
  type        = map(string)
  default = {
    "amd64" = "x86_64"
  }
}

variable "ami_owner_ids" {
  description = "AMI owner id"
  type        = map(string)
  default = {
    "ubuntu" = "099720109477" #Canonical
  }
}

# ---------------- Default ports ---------------------

variable "ssh_port" {
  description = "ssh port"
  type        = number
  default     = 22
}
