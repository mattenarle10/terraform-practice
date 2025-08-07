terraform {
  required_providers {
    aws = {
      source    = "hashicorp/aws"
      version   = "~> 4.18.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "sa-east-1"  
  
  default_tags {
    tags = {
      Project     = "TerraformPractice"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
