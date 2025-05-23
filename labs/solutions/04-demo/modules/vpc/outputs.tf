output "vpc_details" {
  value = {
    id   = aws_vpc.vpc.id
    name = aws_vpc.vpc.tags["Name"]
  }
}

output "subnets" {
  value = { for s in aws_subnet.subnet : s.name => s.id }
}