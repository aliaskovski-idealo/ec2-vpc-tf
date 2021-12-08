data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "3.10.0"
  name                         = "openapm-vpc"
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
  name        = "openapm-allow_ssh"
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
    Name = "openapm-allow_ssh_pub"
  }
}


resource "aws_security_group" "doc-group" {
  name        = "doc_sec_gr"
  description = "htw_doc_sec_gr"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}