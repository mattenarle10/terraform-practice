variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "sa-east-1" # São Paulo region
}

variable "team_name" {
  description = "Team name used for tagging and resource names (S3-safe: letters, numbers, hyphens)"
  type        = string
  default     = "matt"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Name of the project for tagging resources"
  type        = string
  default     = "matt-terraform"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "web_count" {
  description = "Number of EC2 web instances to launch"
  type        = number
  default     = 3
}
