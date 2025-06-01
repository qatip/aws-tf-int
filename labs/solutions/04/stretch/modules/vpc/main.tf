resource "aws_vpc" "lab_vpc" {
  provider = aws
  cidr_block           = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}