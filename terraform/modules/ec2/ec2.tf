resource "aws_key_pair" "motion_key_pair" {
  key_name   = var.key_pair
  public_key = file("motion_key.pem.pub")
}

resource "aws_security_group" "sg_ssh" {
  name        = "sg_ssh"
  description = "sg_ssh"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_shh"
  }
}

resource "aws_security_group" "sg_http_https" {
  name        = "sg_http_https"
  description = "sg_http_https"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_http_https"
  }
}

resource "aws_security_group" "sg_mysql" {
  name        = "sg_mysql"
  description = "sg_mysql"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_cidr_block]
  }

  tags = {
    Name = "sg_mysql"
  }
}

resource "aws_security_group" "sg_8080" {
  name        = "sg_8080"
  description = "sg_8080"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_8080"
  }
}

resource "aws_security_group" "sg_egress" {
  name        = "sg_egress"
  description = "sg_egress"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_egress"
  }
}

resource "aws_instance" "web_server_pitstop" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id]

  subnet_id = var.public_subnet_id

  tags = {
    Name = "web_server_pitstop"
  }
}

resource "aws_eip_association" "association_pitstop" {
  instance_id = aws_instance.web_server_pitstop.id
  allocation_id = "eipalloc-0c0d5ae29d5000f20"
}

resource "aws_instance" "web_server_buscar" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id]

  subnet_id = var.public_subnet_id

  tags = {
    Name = "web_server_buscar"
  }
}

resource "aws_eip_association" "association_buscar" {
  instance_id   = aws_instance.web_server_buscar.id
  allocation_id = "eipalloc-0436067b65beb78ce"
}

resource "aws_instance" "web_server_motion" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id]

  subnet_id = var.public_subnet_id

  tags = {
    Name = "web_server_motion"
  }
}

resource "aws_eip_association" "association_motion" {
  instance_id = aws_instance.web_server_motion.id
  allocation_id = "eipalloc-0a5ea3792bf9a5019"
}

resource "aws_instance" "back_end_pitstop_1" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  private_ip    = "10.0.0.21"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id, aws_security_group.sg_8080.id]

  subnet_id = var.private_subnet_id

  tags = {
    Name = "back_end_pitstop_1"
  }
}

resource "aws_instance" "back_end_pitstop_2" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  private_ip    = "10.0.0.22"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id, aws_security_group.sg_8080.id]

  subnet_id = var.private_subnet_id

  tags = {
    Name = "back_end_pitstop_2"
  }
}

resource "aws_instance" "back_end_buscar_1" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  private_ip    = "10.0.0.23"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id, aws_security_group.sg_8080.id]

  subnet_id = var.private_subnet_id

  tags = {
    Name = "back_end_buscar_1"
  }
}

resource "aws_instance" "back_end_buscar_2" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.defalt_type_instance
  key_name      = aws_key_pair.motion_key_pair.key_name
  private_ip    = "10.0.0.24"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_http_https.id, aws_security_group.sg_egress.id, aws_security_group.sg_8080.id]

  subnet_id = var.private_subnet_id

  tags = {
    Name = "back_end_buscar_2"
  }
}