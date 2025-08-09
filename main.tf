# Data source to get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Networking moved to module
module "aws_network" {
  source             = "./modules/vpc"
  name_prefix        = local.team_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Create Security Group
resource "aws_security_group" "web" {
  name        = "${local.team_name}-allow-ssh-http"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = module.aws_network.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.team_name}-allow-ssh-http"
  }
}

# ALB security group (public)
resource "aws_security_group" "alb" {
  name        = "${local.team_name}-alb-sg"
  description = "Allow HTTP from the internet to ALB"
  vpc_id      = module.aws_network.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.team_name}-alb-sg"
  }
}

# Restrict instance HTTP to ALB only
resource "aws_security_group_rule" "web_http_from_alb" {
  type                     = "ingress"
  description              = "HTTP from ALB"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
}

# ALB + Target group + Listener
resource "aws_lb" "app" {
  name               = "${local.team_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.aws_network.public_subnet_ids

  tags = { Name = "${local.team_name}-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "${local.team_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.aws_network.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = var.web_count
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# DynamoDB moved to a module
module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "${local.team_name}-products-table"
}

# S3 bucket for product images (public read for objects)
resource "aws_s3_bucket" "product_images" {
  bucket = "${local.team_name}-product-images"

  tags = {
    Name        = "${local.team_name}-product-images"
    Environment = "production"
  }
}

resource "aws_s3_bucket_public_access_block" "product_images_pab" {
  bucket                  = aws_s3_bucket.product_images.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "product_images_public_read" {
  statement {
    sid     = "AllowPublicRead"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.product_images.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "product_images_public" {
  bucket     = aws_s3_bucket.product_images.id
  policy     = data.aws_iam_policy_document.product_images_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.product_images_pab]
}

# IAM moved to a module
module "ec2_instance_profile" {
  source       = "./modules/ec2_instance_profile"
  profile_name = local.team_name
  # Optional explicit names to match existing resources
  role_name             = "${local.team_name}-ec2-web-role"
  instance_profile_name = "${local.team_name}-ec2-web-profile"
  policy_name           = "${local.team_name}-ec2-web-access"
  iam_policies = [
    {
      effect = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ]
      resources = [
        module.dynamodb.table_arn
      ]
    },
    {
      effect = "Allow"
      actions = ["s3:PutObject", "s3:PutObjectAcl"]
      resources = ["${aws_s3_bucket.product_images.arn}/*"]
    },
    {
      effect = "Allow"
      actions = ["s3:ListBucket"]
      resources = [aws_s3_bucket.product_images.arn]
    }
  ]
}

# Create EC2 Instance
resource "aws_instance" "web" {
  count                  = var.web_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.aws_network.private_subnet_ids[count.index % length(module.aws_network.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = module.ec2_instance_profile.instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              export DEBIAN_FRONTEND=noninteractive
              apt update -y
              apt install -y python3 python3-pip git nginx

              # Clone the Flask app repository
              git clone ${local.flask_github_repo} /home/ubuntu/app || true
              cd /home/ubuntu/app

              # Set environment for the app
              export AWS_REGION=${local.assigned_aws_region}
              export DYNAMODB_TABLE_NAME=${module.dynamodb.table_name}
              export S3_BUCKET_NAME=${aws_s3_bucket.product_images.bucket}

              # Install Python dependencies
              pip3 install --upgrade pip
              pip3 install -r requirements.txt

              # Start the Flask app
              nohup python3 app.py > /home/ubuntu/app/app.log 2>&1 &

              # Configure NGINX to proxy to Flask app
              tee /etc/nginx/sites-available/default > /dev/null << 'EOL'
              server {
                  listen 80 default_server;
                  listen [::]:80 default_server;
                   client_max_body_size 10m;

                  location / {
                      proxy_pass http://127.0.0.1:5000;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }
              }
              EOL

              systemctl restart nginx
              EOF

  tags = {
    Name = "${local.team_name}-products-instance-${count.index}"
  }
}

# Generate SSH key pair dynamically
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "./.ssh/terraform_rsa"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "./.ssh/terraform_rsa.pub"
  file_permission = "0644"
}

resource "aws_key_pair" "deployer" {
  key_name   = "${local.team_name}-ubuntu-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

