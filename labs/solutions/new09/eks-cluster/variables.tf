variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "The VPC ID for EKS and Cloud9"
  type        = string
}