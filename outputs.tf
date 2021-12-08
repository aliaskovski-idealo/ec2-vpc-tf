output "ec2_instance_id" {
  description = "The ID of the Ec2 instance"
  value       = module.ec2.public_instance_id
}

output "ec2_instance_public_ip" {
  description = "The public IP of the Ec2 instance"
  value       = module.ec2.public_ip
}