terraform {
  backend "s3" {
    bucket         = "matt-terraform-bucket-ecv"
    key            = "state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    # dynamodb_table = "matt-tf-locks"  # Uncomment if you decide to use DynamoDB for state locking
  }
}
