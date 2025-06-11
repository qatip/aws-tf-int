variable "ami_id" {
  type        = string
  description = "AMI to use for EC2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}