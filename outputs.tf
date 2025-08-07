output "ubuntu_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i .ssh/terraform_rsa ubuntu@${aws_instance.web.public_ip}"
}
