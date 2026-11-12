variable "vpcs" {
  type = map(object({
    name       = string
    cidr_block = string
  }))
}

variable "subnets" {
  type = map(map(string))
  default = {
  }
}