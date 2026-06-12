output "vpc_details" {
  value = {
    id   = aws_vpc.vpc.id
    name = aws_vpc.vpc.tags["Name"]
  }
}

output "subnets" {
  value = { for k, v in aws_subnet.subnet : k => v.id }
}
