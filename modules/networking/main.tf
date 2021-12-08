data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "3.10.0"
  name                         = "ghostwriter-vpc"
  cidr                         = var.cidr
  azs                          = data.aws_availability_zones.available.names
  private_subnets              = var.private_subnets
  public_subnets               = var.public_subnets
  database_subnets             = var.database_subnets
  #assign_generated_ipv6_cidr_block = true
  create_database_subnet_group = false
  enable_nat_gateway           = true
  single_nat_gateway           = true
}

# SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "ghostwriter-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the internet"
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
    Name = "ghostwriter-allow_ssh_pub"
  }
}

# SG to only allow connections from bastion host to RDS instance via given port
resource "aws_security_group" "allow_rds_connect" {
  name        = "ghostwriter-allow_rds_connect"
  description = "Allow outbound RDS traffic"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "allow connection to database subnets"
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = var.database_subnets
  }

  tags = {
    Name = "ghostwriter-out_rds_connect"
  }
}

resource "aws_security_group" "alb" {
  name   = "ghostwriter-alb"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ecs_backend" {
  name   = "ecs_backend"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port_backend
    to_port          = var.container_port_backend
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ecs_frontend" {
  name   = "ecs_frontend"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port_frontend
    to_port          = var.container_port_frontend
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
