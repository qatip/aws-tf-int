variable "vpc_name" {}
variable "cidr_block" {}
modules/vpc/outputs.tf:
output "vpc_id" {
  value = aws_vpc.lab_vpc.id
}
