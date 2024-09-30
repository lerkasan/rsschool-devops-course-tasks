**TASK 1**

Prerequisites:
- AWS CLI v2
- Terraform

To create project infrastructure please follow these steps:
1. Configure an AWS role with following permissions: 
	- AmazonEC2FullAccess
	- AmazonRoute53FullAccess
	- AmazonS3FullAccess
	- IAMFullAccess
	- AmazonVPCFullAccess
	- AmazonSQSFullAccess
	- AmazonEventBridgeFullAccess

2. Set values for the following terraform variables in tfvars file or TF_VAR_* environment variables:
	- region
	- project_name
	- environment
	- bucket_name
	- github_repo in format "github_account/github_repository_name"
	- github_actions_role_name = "GithubActionsRole"
	- github_actions_role_permissions = [
        "AmazonEC2FullAccess",
        "AmazonRoute53FullAccess",
        "AmazonS3FullAccess",
    	"IAMFullAccess",
    	"AmazonVPCFullAccess",
    	"AmazonSQSFullAccess",
    	"AmazonEventBridgeFullAccess"
  	  ]
	- tags = {
    	project     = "project-name"
    	task        = "task-01"
    	environment = "dev"
	  }

3. Create AWS S3 bucket for terraform state and put its name as bucket value into `backend.tf` file

4. Go to task1 directory
`cd task1`

5. Run `terraform init`

6. Run `terraform plan`

7. Run `terraform apply` and type "yes" to confirm it.

To destroy infrastructure run `terraform destroy` and confirm it.