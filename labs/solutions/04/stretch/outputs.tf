output "vpc_east_id" {
  value = module.vpc_east.vpc_id
}

output "subnet_east_id" {
  value = module.vpc_east.subnet_id
}

output "vpc_west_id" {
  value = module.vpc_west.vpc_id
}

output "subnet_west_id" {
  value = module.vpc_west.subnet_id
}