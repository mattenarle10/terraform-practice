output "ubuntu_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = join(",", [for i in aws_instance.web : coalesce(i.public_ip, "-")])
}

output "web_instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = join(",", [for i in aws_instance.web : coalesce(i.public_dns, "-")])
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i .ssh/terraform_rsa ubuntu@${aws_instance.web[0].private_ip}"
}

output "products_api_url" {
  description = "Products API URL"
  value       = "http://${aws_lb.app.dns_name}/products"
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "app_url" {
  description = "App URL via ALB"
  value       = "http://${aws_lb.app.dns_name}"
}
