variable "vpc" {
  type = any
}

variable "sg_pub_id" {
  type = any
}

variable "sg_rds_connect_id" {
  type = any
}

variable "ec_bastion_host_size" {
  type = string
}

variable "volume_size" {
  type    = number
  default = 500
}

variable "s3" {
  type = string
}
