provider "aws" {
#  profile = "aws_basics"
   #access_key = "................"
   #secret_key = "................"
   region  = "eu-central-1"
 }

module "networking" {
  source                  = "./modules/networking"
}

module "ec2" {
  source               = "./modules/ec2"
  ec2_size = var.ec2_size
  vpc                  = module.networking.vpc
  sg_pub_id            = module.networking.sg_pub_id
  volume_size          = 10
}

#module "ec2_bastion" {
#  source               = "./modules/ec2"
#  ec2_size = var.ec2_size
#  vpc                  = module.networking.vpc
#  sg_pub_id            = module.networking.sg_pub_id
#  volume_size          = 20
#}