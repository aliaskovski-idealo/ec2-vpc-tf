# Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/install_ec2_instance_connect.sh")
}

# Configure the EC2 instance in a public subnet

resource "aws_instance" "ec2_public" {
  depends_on                  = [aws_iam_role.ec2_to_s3_role]
  ami                         = data.aws_ami.amazon_linux_2.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_role_iam_instance_profile.name
  associate_public_ip_address = true
  instance_type               = var.ec_bastion_host_size
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [
    var.sg_pub_id,
    var.sg_rds_connect_id
  ]
  user_data                   = data.template_file.user_data.rendered
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.volume_size
  }
}

# ------------------------------------------------------------------------------
# policy for users allowing connection
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "instance_connect" {
  name        = "ghostwriter-instance-connect"
  path        = "/allow_connect_access/"
  description = "Allows use of EC2 instance connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  		"Effect": "Allow",
  		"Action": "ec2-instance-connect:SendSSHPublicKey",
  		"Resource": "${aws_instance.ec2_public.arn}",
  		"Condition": {
  			"StringEquals": { "ec2:osuser": "ec2-user" }
  		}
  	},
		{
			"Effect": "Allow",
			"Action": "ec2:DescribeInstances",
			"Resource": "*"
		}
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_role_iam_instance_profile" {
  name = "ghostwriter-instance-profile"
  role = aws_iam_role.ec2_to_s3_role.name
}

resource "aws_iam_role_policy" "ec2_to_s3_role_policy" {
  name   = "ghostwriter-ec2_to_s3_role_policy"
  role   = aws_iam_role.ec2_to_s3_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:GetObjectTagging",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::*/*",
                "${var.s3}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role" "ec2_to_s3_role" {
  name               = "ghostwriter-ec2_to_s3_role"
  description        = "trusted entity of the role"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
