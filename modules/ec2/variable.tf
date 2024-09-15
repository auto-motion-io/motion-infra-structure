variable "key_pair" {
  type    = string
  default = "motion_key"
}

variable "ami_ubuntu_24_04" {
  type    = string
  default = "ami-0e86e20dae9224db8"
}

variable "t2_medium" {
  type    = string
  default = "t2.medium"
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

