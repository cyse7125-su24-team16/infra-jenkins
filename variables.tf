variable "region" {
  description = "Specifies the AWS region where resources will be deployed."
  type        = string
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "env" {
  description = "Defines the deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string

}

variable "public_route_table_cidr_block" {
  description = "The CIDR block for the public route table."
  type        = string
}

variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets within the VPC."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR blocks for the private subnets within the VPC."
  type        = list(string)
}

