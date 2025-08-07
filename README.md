# Terraform Practice Project - Matt

Terraform infrastructure deployment on AWS with complete VPC setup and NGINX web server.

## What I Built

**Challenge 1**: Basic EC2 instance with proper AWS provider configuration  
**Challenge 2**: Complete web server infrastructure with VPC, security groups, and SSH access

## Project Structure

```
terraform-practice/
├── main.tf              # VPC, EC2, security groups, SSH keys
├── providers.tf         # AWS provider with required providers (aws, tls, local)
├── variables.tf         # Configuration variables
├── outputs.tf           # IP addresses and SSH command
└── .ssh/                # Auto-generated SSH keys (terraform_rsa)
```

## Quick Setup

1. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform apply
   ```

3. **Access the web server**:
   - **Web**: Visit the IP from output (e.g., http://56.124.95.35)
   - **SSH**: Use the command from output (e.g., `ssh -i .ssh/terraform_rsa ubuntu@56.124.95.35`)

## What Gets Created

- **VPC**: Custom virtual private cloud (10.0.0.0/16)
- **Public Subnet**: Internet-accessible subnet (10.0.1.0/24)
- **Security Group**: SSH (22), HTTP (80), HTTPS (443) access
- **EC2 Instance**: Ubuntu 22.04 with NGINX pre-installed
- **SSH Keys**: Auto-generated RSA 4096-bit key pair
- **NGINX**: Serves "Hello from Terraform by Matt challenge 2!"

## Key Features

✅ **Auto-generated SSH keys** - No manual key management  
✅ **VPC networking** - Secure isolated environment  
✅ **Security groups** - Proper firewall rules  
✅ **Web server ready** - NGINX installed and configured  
✅ **One-command deployment** - Complete infrastructure in minutes

## Cleanup

```bash
terraform destroy
```
