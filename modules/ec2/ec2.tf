resource "aws_key_pair" "motion_key_pair" {
  key_name   = var.key_pair
  public_key = file("motion_key.pem.pub")
}

resource "aws_security_group" "sg_motion" {
  name        = "sg_motion"
  description = "sg_motion_defalt"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "motion_sg_terraform"
  }
}

resource "aws_instance" "motion_public_instance" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.t2_medium
  key_name      = aws_key_pair.motion_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_motion.id]

  subnet_id = var.public_subnet_id

  tags = {
    Name = "public_ec2_terraform"
  }
}

resource "aws_instance" "motion_private_instance" {
  ami           = var.ami_ubuntu_24_04
  instance_type = var.t2_medium
  key_name      = aws_key_pair.motion_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

  vpc_security_group_ids = [aws_security_group.sg_motion.id]

  subnet_id = var.private_subnet_id

  tags = {
    Name = "private_ec2_terraform"
  }
}