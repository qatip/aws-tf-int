variable "vpc_east_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_west_cidr" {
  default = "10.1.0.0/16"
}

variable "subnet_east_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_west_cidr" {
  default = "10.1.1.0/24"
}