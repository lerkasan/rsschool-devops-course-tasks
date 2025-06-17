TASK 1

This task provides Terraform code to create AWS resources that are necessary to bootstrap a new infrastructure project:
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

    *Examples of values for these variables can be found in the file **variables.tfvars.example***

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

    *Examples of values for these variables can be found in the file **variables.tfvars.example***

2. Create the following secrets in your GitHub repository:
    - TERRAFORM_ROLE with a value that equals ARN of the IAM role created earlier for GitHub Actions 
    - INFRACOST_API_KEY if you want to use Infracost tool, otherwise delete steps related to Infracost from terraform-plan job in GitHub Actions workflow.