resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = each.value.name
  }
}