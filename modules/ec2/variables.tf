variable "vpc" {
  type = any
}

variable "sg_pub_id" {
  type = any
}

variable "ec2_size" {
  type = string
}

variable "volume_size" {
  type    = number
  default = 10
}
