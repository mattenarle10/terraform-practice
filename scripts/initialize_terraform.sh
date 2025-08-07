#!/bin/bash

# Script to initialize Terraform with S3 backend
# This script assumes the S3 bucket has already been created

# Check if backend.tf is still commented
if grep -q "^\/\*" backend.tf; then
  echo "Uncommenting backend configuration in backend.tf..."
  # Remove comment markers from backend.tf
  sed -i.bak 's/\/\*//g' backend.tf
  sed -i.bak 's/\*\///g' backend.tf
  rm -f backend.tf.bak
  echo "Backend configuration uncommented."
else
  echo "Backend configuration already uncommented."
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

if [ $? -ne 0 ]; then
  echo "Error initializing Terraform. Please check your configuration and AWS credentials."
  exit 1
fi

echo "Terraform initialized successfully with S3 backend."
echo "You can now run 'terraform plan' to preview changes."
