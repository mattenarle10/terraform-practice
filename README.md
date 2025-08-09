# Terraform Practice Project - Matt

Terraform infrastructure deployment on AWS with complete VPC setup and NGINX web server.

## What I Built

**Challenge 1**: First Deployment on Terraform
   Activity 1: Create your first EC2 Instance 
   Activity 2: Nginx Web Server
   Activity 3: Add in a basic Python application 
   Bonus: Create Product

**Challenge 2**: First Module in Terraform
   Activity 1: Creating our first module (EC2)
   Activity 2: Modularize the EC2 Instance Profile
   Activity 3: Let’s build our own VPC
   Bonus Activity A: Modularize the DynamoDB
   Bonus Activity B: Upgrade EC2 with ALB (public) and EC2 in private subnet
   Bonus Activity C: Scale out EC2 using count and register all to ALB

## Project Structure

```
terraform-practice/
├── main.tf              # Root config: modules wiring, EC2, ALB, SGs
├── providers.tf         # AWS provider with required providers (aws, tls, local)
├── variables.tf         # Configuration variables
├── outputs.tf           # Outputs (ALB DNS, app URL, SSH helper)
├── modules/
│   ├── ec2/                 # EC2 module (reusable)
│   ├── ec2_instance_profile/# IAM role + instance profile
│   ├── vpc/                 # VPC with public/private subnets, IGW, NAT, routes
│   └── dynamodb/            # DynamoDB table module
└── .ssh/                    # Auto-generated SSH keys (terraform_rsa)
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

3. **Access the app**:
   - **Web**: Visit the ALB URL from outputs (e.g., http://<alb_dns_name>)
   - **SSH**: Use the command from outputs (connects to a private IP via your network tooling)

## What Gets Created

- **VPC**: Custom VPC with public and private subnets, IGW, NAT, routes
- **ALB**: Application Load Balancer in public subnets with HTTP listener
- **EC2**: Ubuntu 22.04 instances in private subnets behind the ALB (scaled via `count`)
- **Security Groups**: ALB open on 80; web instances allow HTTP only from ALB; SSH helper output
- **DynamoDB**: Products table (module)
- **S3**: Bucket for product images with read policy
- **SSH Keys**: Auto-generated RSA 4096-bit key pair

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
