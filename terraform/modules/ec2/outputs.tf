output "public_ip_buscar" {
  value = aws_eip_association.association_buscar.public_ip
  description = "IP publico do web server buscar"
}

output "public_ip_pitstop" {
  value = aws_eip_association.association_pitstop.public_ip
  description = "IP publico do web server pitstop"
}

output "public_ip_motion" {
  value = aws_eip_association.association_motion.public_ip
  description = "IP publico do web server motion"
}