variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.s3_bucket_name))
    error_message = "S3 bucket name must be lowercase, alphanumeric or hyphens, 3-63 chars."
  }
}

variable "iam_role_name" {
  description = "IAM role name to assign"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Only approved instance types (t2.micro, t3.micro, t3.small) are allowed."
  }
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}