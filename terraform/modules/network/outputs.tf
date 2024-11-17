output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
  description = "ID da subnet pública"
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
  description = "ID da subnet privada"
}

output "vpc_id" {
  value = aws_vpc.motion_vpc.id
  description = "ID da VPC"
}

output "private_cidr_block" {
  value = var.private_subnet_cidr_block
  description = "cidr block da subnet privada"
}