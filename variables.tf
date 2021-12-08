variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
  type        = string
}

variable "ec2_size" {
  type    = string
  default = "t2.medium"
}