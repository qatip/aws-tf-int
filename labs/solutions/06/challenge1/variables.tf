variable "s3_bucket_name" {
  description = "S3 Bucket Name (Must contain bucket1 through buckets6)"
  type        = string
}

variable "environment" {
  description = "Environment (Must be DEV, PROD, or TEST)"
  type        = string
}