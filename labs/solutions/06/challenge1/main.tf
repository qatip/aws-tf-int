resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name

  tags = {
    Environment = upper(var.environment)
    UpdatedOn   = formatdate("YYYY-MM-DD", timestamp())
  }

  lifecycle {
    precondition {
      condition     = contains(["BUCKET1", "BUCKET2", "BUCKET3", "BUCKET4", "BUCKET5", "BUCKET6"], var.s3_bucket_name)
      error_message = "S3 bucket name must be BUCKET1 to BUCKET6."
    }
    precondition {
      condition     = contains(["DEV", "PROD", "TEST"], upper(var.environment))
      error_message = "Environment must be one of DEV, PROD, or TEST."
    }
  }
}