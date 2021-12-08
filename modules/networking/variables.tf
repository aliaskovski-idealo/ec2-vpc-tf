variable "rds_port" {
  type = string
}

# REPLACE IF YOU HAVE MULTIPLE SETUPS IN ONE ACCOUNT

variable "cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

variable "database_subnets" {
  type    = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
}

variable "container_port_backend" {
  type = number
}

variable "container_port_frontend" {
  type = number
}
