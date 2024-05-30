output "region" {
  value = var.region
}

output "env" {
  value = var.env
}

output "Vpc_id" {
  value = aws_vpc.VPC.id
}

output "Public_Subnets" {
  value = aws_subnet.Public_Subnets[*].id
}

output "Private_subnets" {
  value = aws_subnet.Private_subnets[*].id
}

output "Igw_Id" {
  value = aws_internet_gateway.Igw.id
}

output "aws_security_group" {
  value = aws_security_group.Jenkins_Security_Group.id
}

output "aws_instance" {
  value = aws_instance.Jenkins_Instance.id
}
output "ssh_key_name" {
  value = aws_key_pair.Jenkins_Key.key_name
}