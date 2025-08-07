terraform {
  backend "s3" {
    bucket         = "mattenarle-terraform-bucket"
    key            = "state/terraform.tfstate"
    region         = "sa-east-1"
    encrypt        = true
    # dynamodb_table = "matt-tf-locks"  # uncpmment alter if dyanmo is used
  }
}
