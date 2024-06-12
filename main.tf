# Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


provider "aws" {
  region = var.region
  #profile = "AnushaRoot"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

}

# Data Source Configuration for Availability Zones.
data "aws_availability_zones" "available_zones" {}

# Creating a Virtual Private Cloud (VPC).
resource "aws_vpc" "VPC" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.env}-Vpc"
    Environment = "${var.env}"
  }
}

# Creating Internet Gateway and attaching it to the VPC.
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name        = "${var.env}-Internet-Gateway"
    Environment = "${var.env}"
  }
}

# Creating a public route table and adding a route to the internet gateway.
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = var.public_route_table_cidr_block
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name        = "${var.env}-Public-Route-Table"
    Environment = "${var.env}"
  }
}

# Creating public subnets.
resource "aws_subnet" "Public_Subnets" {
  map_public_ip_on_launch = true
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index % length(data.aws_availability_zones.available_zones.names)]

  tags = {
    Name        = "${var.env}-Public-Subnet-${count.index}"
    Environment = "${var.env}"
  }
}

# Attaching public route table with public subnets.
resource "aws_route_table_association" "Public_Route_Table_Association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_Route_Table.id
}

# Creating private subnets.
resource "aws_subnet" "Private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available_zones.names[count.index % length(data.aws_availability_zones.available_zones.names)]

  tags = {
    Name        = "${var.env}-Private-subnet-${count.index}"
    Environment = "${var.env}"
  }
}

# Creating a security group for Jenkins.
resource "aws_security_group" "Jenkins_Security_Group" {
  name   = "Jenkins_Security_Group"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port   = var.https_ports
    to_port     = var.https_ports
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JenkinsSecurityGroup"
  }
}

# Creating a network interface for Jenkins server.
resource "aws_network_interface" "JenkinsServerNIC" {
  subnet_id       = aws_subnet.Public_Subnets[0].id
  security_groups = [aws_security_group.Jenkins_Security_Group.id]
  tags = {
    Name = "JenkinsServerNIC"
  }
}

# Attaching an Elastic IP and associating it with the network interface.
resource "aws_eip_association" "Jenkins_Elastic_IP_Association" {
  network_interface_id = aws_network_interface.JenkinsServerNIC.id
  allocation_id        = var.allocation_id
}

resource "aws_instance" "Jenkins_Instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.JenkinsServerNIC.id
    device_index         = 0
  }

  tags = {
    Name = "Jenkins EC2 Instance"
  }
}
resource "aws_key_pair" "Jenkins_Key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/${var.ssh_key_file}")
}

