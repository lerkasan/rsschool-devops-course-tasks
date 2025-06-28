**TASK 2**

This main part of terraform code is located in `infra` directory and divided into 3 modules: 
   - vpc
   - ec2
   - ec2_instance_connect_endpoint

The code creates:
   - 2 public subnets in different AZs
   - 2 private subnets in different AZs
   - Internet Gateway
   - 2 NAT Gateways (1 NAT Gateway in each public subnet)
   - Bastion server in a public subnet
   - 2 Application servers in private subnets (1 Application server in each private subnet)
   - 1 EC2 Instance Connect Endpoint in order to be able to directly connect to Application servers without a Bastion server
   - Routing configuration:
     - Instances in all subnets can reach each other
     - Instances in public subnets can reach addresses outside VPC and vice-versa


Here is an example of variables used to create this infrastructure:

```
vpcs = [
  {
    name                     = "rsschool-vpc-1"
    cidr_block               = "10.1.0.0/16"
    public_subnets           = ["10.1.10.0/24", "10.1.20.0/24"]
    private_subnets          = ["10.1.230.0/24", "10.1.240.0/24"]
    enable_dns_hostnames     = true
    enable_dns_support       = true
    enable_flow_logs         = true
    flow_logs_retention_days = 365

    tags = {
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_bastions = [
  {
    ec2_instance_type           = "t3.micro"
    vpc_cidr                    = "10.1.0.0/16"
    subnet_cidr                 = "10.1.10.0/24"
    associate_public_ip_address = true
    volume_type                 = "gp3"
    volume_size                 = 10
    delete_on_termination       = true
    private_ssh_key_name        = "bastion_rsschool_ssh_key_pair"
    admin_public_ssh_key_names  = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "BastionHost"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_appservers = [
  {
    ec2_instance_type     = "t3.micro"
    vpc_cidr              = "10.1.0.0/16"
    subnet_cidr           = "10.1.230.0/24"
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
    private_ssh_key_name  = "appserver_rsschool_ssh_key_pair"
    enable_bastion_access = true
    bastion_name          = "BastionHost"
    admin_public_ssh_key_names           = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "AppServer-1"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  },
  {
    ec2_instance_type           = "t3.micro"
    vpc_cidr                    = "10.1.0.0/16"
    subnet_cidr                 = "10.1.240.0/24"
    associate_public_ip_address = false
    enable_bastion_access       = true
    bastion_name                = "BastionHost"
    volume_type                 = "gp3"
    volume_size                 = 10
    delete_on_termination       = true
    private_ssh_key_name        = "appserver_rsschool_ssh_key_pair"
    admin_public_ssh_key_names  = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "AppServer-2"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_instance_connect_endpoints = [
  {
    vpc_cidr    = "10.1.0.0/16"
    subnet_cidr = "10.1.240.0/24"
    tags = {
      "Name"        = "ec2-instance-connect-endpoint"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]
```

In this example, `appserver_rsschool_ssh_key_pair` and `bastion_rsschool_ssh_key_pair` refer to the names of Key Pairs that should be created beforehand and downloaded manually on AWS Console website. These Key Pairs will be associated with EC2 instances of Bastion server and Application servers correspondently.

Moreover, `admin_public_ssh_key_names` represents a list of names of SSM parameters in SSM Parameter Store. Values (represented as strings) of these SSM parameters can include additional public keys for SSH access to servers. Those public keys will be added to servers using cloud-init via userdata.

Prerequisites:

- AWS CLI v. 2.27 and higher
- Terraform v. 1.12 and higher


To run Terraform code locally please follow these steps:

1. Create an IAM user with following permissions:

    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess
    - AmazonSQSFullAccess
    - AmazonEventBridgeFullAccess

2. Set values for the following terraform variables in tfvars file or TF_VAR_* environment variables:

    - region
    - admin_public_ips
    - vpcs
    - ec2_bastions
    - ec2_appservers
    - ec2_instance_connect_endpoints

    *Examples of values for these variables can be found in the file **infra/variables.tfvars.example***

3. Create S3 bucket for terraform state and put its name as bucket value into backend.tf file

4. Run following commands in terminal:

    `terraform init`

    `terraform plan` and verify the intended changes

    `terraform apply` and verify the intended changes again, type "yes" to confirm or "no" to cancel.

5. To destroy infrastructure run `terraform destroy` and type "yes" to confirm.


To configure GitHub variables and secrets necessary for GitHub Actions workflow please follow these steps:

1. Create the following variables in your GitHub repository:
    - REGION
    - TERRAFORM_VERSION
    - EC2_BASTIONS
    - EC2_APPSERVERS
    - EC2_INSTANCE_CONNECT_ENDPOINT

    *Examples of values for these variables can be found in the file **infra/variables.tfvars.example***

2. Create the following secrets in your GitHub repository:
    - TERRAFORM_ROLE with a value that equals ARN of the IAM role created earlier for GitHub Actions 
    - INFRACOST_API_KEY if you want to use Infracost tool, otherwise delete steps related to Infracost from terraform-plan job in GitHub Actions workflow.

______________________________________________________________________________-

TASK 1

This task provides Terraform code in `bootstrap` directory to create AWS resources that are necessary to bootstrap a new infrastructure project:
- S3 bucket for Terraform state
- IAM group
- IAM user to run Terraform code locally
- IAM role to be assumed by GitHub Action with permissions to run Terraform code
- OIDC provider to authenticate GitHub Action with AWS
- GitHub Actions workflow that validates, plans, and applies Terraform code

IAM group, IAM user and IAM role have permissions listed below:
- AmazonEC2FullAccess
- AmazonRoute53FullAccess
- AmazonS3FullAccess
- IAMFullAccess
- AmazonVPCFullAccess
- AmazonSQSFullAccess
- AmazonEventBridgeFullAccess

Prerequisites:

- AWS CLI v. 2.27 and higher
- Terraform v. 1.12 and higher


To run Terraform code locally please follow these steps:

1. Create an IAM user with following permissions:

    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess
    - AmazonSQSFullAccess
    - AmazonEventBridgeFullAccess

2. Set values for the following terraform variables in tfvars file or TF_VAR_* environment variables:

    - region
    - s3_buckets
    - users
    - groups
    - oidc_roles

    *Examples of values for these variables can be found in the file **bootstrap/variables.tfvars.example***

3. Create S3 bucket for terraform state and put its name as bucket value into backend.tf file

4. Run following commands in terminal:

    `terraform init`

    `terraform plan` and verify the intended changes

    `terraform apply` and verify the intended changes again, type "yes" to confirm or "no" to cancel.

5. To destroy infrastructure run `terraform destroy` and type "yes" to confirm.


To configure GitHub variables and secrets necessary for GitHub Actions workflow please follow these steps:

1. Create the following variables in your GitHub repository:
    - REGION
    - TERRAFORM_VERSION
    - S3_BUCKETS
    - IAM_GROUPS
    - IAM_USERS
    - OIDC_ROLES

    *Examples of values for these variables can be found in the file **bootstrap/variables.tfvars.example***

2. Create the following secrets in your GitHub repository:
    - TERRAFORM_ROLE with a value that equals ARN of the IAM role created earlier for GitHub Actions 
    - INFRACOST_API_KEY if you want to use Infracost tool, otherwise delete steps related to Infracost from terraform-plan job in GitHub Actions workflow.