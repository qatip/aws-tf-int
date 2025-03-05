variable "s3_bucket_name" {
  description = "S3 Bucket Name (Must be BUCKET1 to BUCKET6)"
  type        = string
}

variable "environment" {
  description = "Environment (Must be DEV, PROD, or TEST)"
  type        = string
}