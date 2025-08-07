#!/bin/bash

# Script to create an S3 bucket for Terraform state management
# Usage: ./create_s3_bucket.sh [bucket-name] [region]

# Default values
BUCKET_NAME=${1:-"matt-terraform-bucket"}
REGION=${2:-"us-east-2"}

echo "Creating S3 bucket for Terraform state management..."
echo "Bucket name: $BUCKET_NAME"
echo "Region: $REGION"

# Create the bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

if [ $? -ne 0 ]; then
  echo "Error creating bucket. Check if the bucket name is already taken or if you have proper AWS credentials."
  exit 1
fi

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

if [ $? -ne 0 ]; then
  echo "Error enabling versioning on the bucket."
  exit 1
fi

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

if [ $? -ne 0 ]; then
  echo "Error enabling encryption on the bucket."
  exit 1
fi

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

if [ $? -ne 0 ]; then
  echo "Error blocking public access on the bucket."
  exit 1
fi

echo "S3 bucket '$BUCKET_NAME' created successfully with versioning and encryption enabled."
echo "To configure Terraform to use this bucket for state management:"
echo "1. Uncomment the backend configuration in backend.tf"
echo "2. Update the bucket name, region, and key path if needed"
echo "3. Run 'terraform init' to initialize the backend"
