variable "cidr_block" {
  type    = string
  default = "10.0.0.0/27"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/28"
}


variable "private_subnet_cidr_block" {
  type    = string
  default = "10.0.0.16/28"
}