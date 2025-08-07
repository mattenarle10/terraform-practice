# Terraform Practice Project

This project demonstrates advanced Terraform state management and infrastructure deployment on AWS.

## Prerequisites

- Terraform installed locally (v1.2.0+)
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create resources

## Project Structure

```
terraform-practice/
├── main.tf              # Main infrastructure configuration
├── providers.tf         # AWS provider configuration
├── variables.tf         # Input variables
├── backend.tf           # S3 backend configuration (to be enabled)
├── scripts/
│   └── setup_web_app.sh # Script for setting up the Python web application
└── ssh/
    ├── terraform-key     # Private SSH key (gitignored)
    └── terraform-key.pub # Public SSH key
```

## Setup Instructions

### 1. Install Terraform

If not already installed:

```bash
# For macOS with Homebrew
brew install terraform
```

### 2. Create S3 Bucket for State Management

Create an S3 bucket named `matt-terraform-bucket` in the AWS console or using AWS CLI:

```bash
aws s3api create-bucket \
  --bucket matt-terraform-bucket \
  --region sa-east-1 \
  --create-bucket-configuration LocationConstraint=sa-east-1
```

Enable bucket versioning:

```bash
aws s3api put-bucket-versioning \
  --bucket matt-terraform-bucket \
  --versioning-configuration Status=Enabled
```

### 3. Configure Backend

After creating the S3 bucket, uncomment and update the backend configuration in `backend.tf`.

### 4. Initialize and Apply Terraform Configuration

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 5. Access the EC2 Instance

After successful deployment, use the SSH key to connect to the instance:

```bash
ssh -i ssh/terraform-key ubuntu@$(terraform output -raw web_instance_public_ip)
```

The web application will be accessible at: http://[EC2_PUBLIC_IP]

## Best Practices Implemented

- **Remote State Management**: Using S3 for secure, centralized state storage
- **Infrastructure as Code**: Complete infrastructure defined in version-controlled code
- **Security**: Custom VPC with proper security groups and SSH key authentication
- **Automation**: Automated web application deployment via user_data script
- **Modularity**: Separated configuration files for better organization
- **Documentation**: Comprehensive README with setup instructions

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

## Notes

- This is a development environment setup. For production, additional security measures would be recommended.
- The SSH key is generated locally and should be kept secure.
