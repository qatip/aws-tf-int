
variable "region" {
  default = "eu-west-2"
}


variable "instance_type" {
  default = "m5.large"
}

variable "key_name" {
  description = "Name of your EC2 Key Pair"
  default = "my-sql-lab-key"
}

