variable "vpcs" {
  type = map(object({
    name       = string
    cidr_block = string
    region     = string
  }))
  default = {
    vpc1 = { name = "vpc-01", cidr_block = "10.0.0.0/16", region = "us-east-1" }
    vpc2 = { name = "vpc-02", cidr_block = "10.1.0.0/16", region = "us-east-1" }
  }
}

variable "subnets" {
  type = map(map(string))
  default = {
    "vpc1" = {
      "subnet-01" = "10.0.1.0/24"
      "subnet-02" = "10.0.2.0/24"
    }
    "vpc2" = {
      "subnet-03" = "10.1.1.0/24"
      "subnet-04" = "10.1.2.0/24"
    }
  }
}