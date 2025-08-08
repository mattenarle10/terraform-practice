variable "ami_id" {
  type        = string
  description = "AMI ID to use for the instance"
}

variable "instance_type" {
  type        = string
  description = "The type of instance to launch."
  default     = "t3.micro"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance should be launched"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with the instance"
}

variable "keypair_name" {
  type        = string
  description = "The key name used to SSH into the EC2 instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "The name of the IAM instance profile"
}

variable "user_data" {
  type        = string
  description = "The script you want to run upon startup"
}

variable "ec2_instance_name" {
  type        = string
  description = "The name of the EC2 instance"
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP with the instance"
  default     = true
}


