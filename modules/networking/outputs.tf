output "vpc" {
  value = module.vpc
}

output "alb_security_group" {
  value = aws_security_group.alb.id
}

output "ecs_backend_security_group" {
  value = aws_security_group.ecs_backend.id
}

output "ecs_frontend_security_group" {
  value = aws_security_group.ecs_frontend.id
}

output "sg_pub_id" {
  value = aws_security_group.allow_ssh_pub.id
}

output "sg_rds_connect_id" {
  value = aws_security_group.allow_rds_connect.id
}
