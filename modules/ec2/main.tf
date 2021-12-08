# Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}


data "template_file" "user_data" {
  template = file("${path.module}/install_ec2_docker.sh")
}

# Configure the EC2 instance in a public subnet

resource "aws_instance" "ec2_public" {
  key_name = "test_01_key"
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.ec2_size
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [
    var.sg_pub_id
  ]
  user_data                   = data.template_file.user_data.rendered
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.volume_size
  }
}

