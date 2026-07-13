terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

########################
# VPC
########################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "microservices-vpc"
  }
}

########################
# INTERNET GATEWAY
########################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "microservices-igw"
  }
}

########################
# PUBLIC SUBNET
########################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

########################
# ROUTE TABLE
########################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

########################
# SECURITY GROUP
########################

resource "aws_security_group" "k3s_sg" {
  name   = "k3s-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Internal Communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# MASTER NODE
########################

resource "aws_instance" "master" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public.id
  key_name               = "ubuntu"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "k3s-master"
  }
}

########################
# WORKER 1
########################

resource "aws_instance" "worker1" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public.id
  key_name               = "ubuntu"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "k3s-worker1"
  }
}

########################
# WORKER 2
########################

resource "aws_instance" "worker2" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public.id
  key_name               = "ubuntu"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "k3s-worker2"
  }
}

########################
# OUTPUTS
########################

output "master_ip" {
  value = aws_instance.master.public_ip
}

output "worker1_ip" {
  value = aws_instance.worker1.public_ip
}

output "worker2_ip" {
  value = aws_instance.worker2.public_ip
}