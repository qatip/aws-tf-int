variable "vpc_name" {}
variable "cidr_block" {}
variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
  }))
  default = []
}