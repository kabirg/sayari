provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.resource_name_prefix}_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_name_prefix}_public_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_name_prefix}_igw"
  }
}

resource "aws_security_group" "webserver_sg" {
  name   = "webserver_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_name_prefix}_sg"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.resource_name_prefix}_public_rt"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Webserver
resource "aws_instance" "webserver" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.ec2_keypair
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webserver_sg.id]

  tags = {
    Name = "${var.resource_name_prefix}_webserver"
  }

  # Install required software: Ansible, Git and Python/Pip
  # Use Ansible Playbook to Install/Configure Docker and Run the application/webserver
  user_data = <<-EOF
              #!/bin/bash
              yum update -y $> root/status.txt
              echo "\n-------------------------------------\n" >> root/status.txt
              yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &>> /root/status.txt
              yum install -y git ansible &>> /root/status.txt
              git clone https://github.com/kabirg/sayari.git /root/sayari-codebase &>> /root/status.txt
              echo "\n-------------------------------------\n" >> root/status.txt
              ansible-playbook /root/sayari-codebase/ansible/main.yml -i /root/sayari-codebase/ansible/inventory &>> /root/status.txt
              # Allow new group to take effect (can't reboot or reset-connection within Ansible if using localhost connection)
              newgrp docker &>> /root/status.txt
              echo "userdata script complete!" > /root/userdata_status.txt
              EOF
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webserver.id
  allocation_id = aws_eip.eip.id
}
