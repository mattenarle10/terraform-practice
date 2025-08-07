# This file will be configured after creating the S3 bucket
# Uncomment and update the values after creating your S3 bucket

/*
terraform {
  backend "s3" {
    bucket         = "matt-terraform-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    # dynamodb_table = "matt-tf-locks"  # Uncomment if you decide to use DynamoDB for state locking
  }
}
*/
