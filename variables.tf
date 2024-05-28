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
 
variable "ami_prefix" {
  description = "Prefix for the AMI name."
  type        = string
}
 
variable "Root_Account_Id" {
  type = list(string)
}
 
variable "instance_type" {
  description = "The type of instance to use for the Jenkins server."
  type        = string
}
 
variable "key_name" {
  description = "The name of the SSH key pair to use for accessing the instance."
  type        = string
}
 
variable "ssh_key_file" {
  description = "The path to the SSH public key file."
  type        = string
}
 
variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}
 
variable "allocation_id" {
  description = "The allocation ID of the existing Elastic IP."
  type        = string
}
 
