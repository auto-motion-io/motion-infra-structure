resource "aws_vpc" "motion_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "motion_vpc_terraform"
  }
}

resource "aws_internet_gateway" "ig_motion" {
  vpc_id = aws_vpc.motion_vpc.id

  tags = {
    Name = "ig_motion_terraform"
  }
}

resource "aws_route_table" "rt_motion_pb" {
  vpc_id = aws_vpc.motion_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_motion.id
  }

  tags = {
    Name = "public_rt_terraform"
  }
}

resource "aws_route_table_association" "association_pb" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_motion_pb.id
}



resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.motion_vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_terraform"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.motion_vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet_terraform"
  }
}

resource "aws_eip" "eip_nat_motion" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_motion" {
  allocation_id = aws_eip.eip_nat_motion.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "Nat_motion_terraform"
  }
}

resource "aws_route_table" "rt_motion_pv" {
  vpc_id = aws_vpc.motion_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_motion.id
  }

  tags = {
    Name = "private_rt_motion"
  }
}

resource "aws_route_table_association" "association_pv" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.rt_motion_pv.id
}

resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.motion_vpc.id

  tags = {
    Name = "public_acl_terraform"
  }
}

resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.motion_vpc.id

  tags = {
    Name = "private_acl_terraform"
  }
}

resource "aws_network_acl_rule" "inbound_ssh_pv" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number = 100
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "10.0.0.0/28"
  from_port = 22
  to_port = 22
}

resource "aws_network_acl_rule" "inbound_all_pv" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number = 200
  egress = false
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}



resource "aws_network_acl_rule" "outbound_pv" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number = 100
  egress = true
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_network_acl_rule" "inbound_all_pb" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number = 100
  egress = false
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_network_acl_rule" "inbound_ssh_pb" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number = 200
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

resource "aws_network_acl_rule" "inbound_http_pb" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number = 300
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_network_acl_rule" "inbound_https_pb" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number = 400
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "outbound_pb" {
  network_acl_id = aws_network_acl.public_acl.id
  rule_number = 100
  egress = true
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_network_acl_association" "association_acl_pb" {
  subnet_id = aws_subnet.public_subnet.id
  network_acl_id = aws_network_acl.public_acl.id
}

resource "aws_network_acl_association" "association_acl_pv" {
  subnet_id = aws_subnet.private_subnet.id
  network_acl_id = aws_network_acl.private_acl.id
}