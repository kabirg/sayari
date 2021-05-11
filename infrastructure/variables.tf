variable "resource_name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}


variable "ec2_keypair" {
  type = string
}

# RHEL 7 AMI
variable "ami" {
  type = string
}
