provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
