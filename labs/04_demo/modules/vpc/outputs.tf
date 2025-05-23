output "vpc_details" {
  value = {
    id   = aws_vpc.vpc.id
    name = aws_vpc.vpc.tags["Name"]
  }
}

output "subnets" {
  value = { for k, s in aws_subnet.subnet : k => s.id }
}