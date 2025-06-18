resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name

  tags = {
    Environment = 
    UpdatedOn   = 
  }

  lifecycle {
    precondition {
      condition     = 
      error_message = "S3 bucket name must be bucket1 to bucket2."
    }
    precondition {
      condition     = 
      error_message = "Environment must be one of DEV, PROD, or TEST."
    }
  }
}