terraform {
  required_providers {
    aws = {
      source    = "hashicorp/aws"
      version   = "~> 4.18.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"  
  
  default_tags {
    tags = {
      Project     = "TerraformPractice"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
