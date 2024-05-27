# Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
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

#Creating Internet Gateway and attaching it to the VPC.
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name        = "${var.env}-Internet-Gateway"
    Environment = "${var.env}"
  }
}

#Creating a public route table and adding a route to the internet gateway.
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

# Creating 2 public subnets each in different availability zones in the same region as the VPC.
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

#Attaching public route table with public subnets.
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_Route_Table.id
}


# Create 2 private subnets, each in different availability zones in the same region as the VPC.
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

#Creating a security group for Jenkins.
resource "aws_security_group" "Jenkins_Security_Group" {
  name = "Jenkins_Security_Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.VPC.id
}

