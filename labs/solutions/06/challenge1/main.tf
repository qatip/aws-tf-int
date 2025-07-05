resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name

  tags = {
    Environment = upper(var.environment)
    UpdatedOn   = formatdate("YYYY-MM-DD", timestamp())
  }

  lifecycle {
    precondition {
      condition     = contains(["bucket1", "bucket2", "bucket3", "bucket4", "bucket5", "bucket6"], var.s3_bucket_name)
      error_message = "S3 bucket name must contain bucket1 through to bucket6."
    }
    precondition {
      condition     = contains(["DEV", "PROD", "TEST"], upper(var.environment))
      error_message = "Environment must be one of DEV, PROD, or TEST."
    }
  }
}