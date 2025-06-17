
variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "m5.large"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  default = "my-sql-lab-key"
}
