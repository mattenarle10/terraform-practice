output "instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.ec2_role.name
}


