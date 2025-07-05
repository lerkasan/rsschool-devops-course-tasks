output "security_group_id" {
  description = "Security group ID of the EC2 instance"
  value       = aws_security_group.ec2_instance.id
}

output "iam_role_name" {
  description = "IAM role name of the EC2 instance"
  value       = aws_iam_role.this.name
}

output "vpc_id" {
  description = "VPC ID of the EC2 instance"
  value       = var.vpc_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}