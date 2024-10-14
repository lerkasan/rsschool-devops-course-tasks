
**TASK 2**

This terraform code creates:
   - 2 public subnets in different AZs
   - 2 private subnets in different AZs
   - Internet Gateway
   - NAT Gateway
   - Bastion server in a public subnet
   - Application server in a private subnet
   - Routing configuration:
     - Instances in all subnets can reach each other
     - Instances in public subnets can reach addresses outside VPC and vice-versa

A custom module Subnet (located in modules/subnet) simplifies subnet creation by combining aws_subnet resource and aws_route_table_association resource into one object.

Here is te example of variables used to create this infrastructure:

```aws_region      = "us-east-1"
az_letters      = ["a", "b"]
cidr            = "10.0.0.0/16"
public_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
private_subnets = ["10.0.240.0/24", "10.0.250.0/24"]

ec2_instance_type  = "t3.micro"
os                 = "ubuntu"
os_product         = "server"
os_version         = "22.04"
os_architecture    = "amd64"
ami_virtualization = "hvm"

bastion_instance_type  = "t2.micro"

appserver_private_ssh_key_name = "appserver_ssh_key_pair"
bastion_private_ssh_key_name   = "bastion_ssh_key_pair"
admin_public_ssh_keys          = ["ssh_public_key"]
```

In this example, `appserver_private_ssh_key_name` and `bastion_private_ssh_key_name` refer to the names of Key Pairs that should be created beforehand and downloaded manually on AWS Console website. These Key Pairs will be associated with EC2 instances of Bastion server and Application server correspondently.

Moreover, `admin_public_ssh_keys` represents a list of names of SSM parameters in SSM Parameter Store. Values (represented as strings) of these SSM parameters can include additional public keys for SSH access to servers. Those public keys will be added to servers using cloud-init via userdata.

 **Results:**

 Resource map screenshot:
![Alt text](img/vpc.png "VPC Resource Map")


 The private subnet with the application server:
![Alt text](img/private_subnet.png "Private Subnet")


 The networking configuration of the application server:
![Alt text](img/appserver.png "Appserver Network")


SSH connection to the application server (in private subnet) through the bastion server. Confirmation that the application server can reach Internet via the NAT Gateway.
![Alt text](img/bastion.png "Bastion and Application Server Connectivity")


Output of `terraform apply`:
![Alt text](img/tf_apply.png "Terraform Apply")


Output of `terraform plan`:
![Alt text](img/tf_plan01.png "Terraform Plan")
![Alt text](img/tf_plan02.png "Terraform Plan")
![Alt text](img/tf_plan03.png "Terraform Plan")
![Alt text](img/tf_plan04.png "Terraform Plan")
![Alt text](img/tf_plan05.png "Terraform Plan")
![Alt text](img/tf_plan06.png "Terraform Plan")
![Alt text](img/tf_plan07.png "Terraform Plan")
![Alt text](img/tf_plan08.png "Terraform Plan")
![Alt text](img/tf_plan09.png "Terraform Plan")
![Alt text](img/tf_plan10.png "Terraform Plan")
![Alt text](img/tf_plan11.png "Terraform Plan")
![Alt text](img/tf_plan12.png "Terraform Plan")
![Alt text](img/tf_plan13.png "Terraform Plan")
![Alt text](img/tf_plan14.png "Terraform Plan")

