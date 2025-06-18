## task 1
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

## task 2
resource "aws_s3_bucket" "bucket_1" {
  bucket = "michaelcg-storage-bucket-123"
  force_destroy = true  # Optional: Allows deleting even if non-empty
}


## task 3
locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

resource "aws_s3_object" "uploaded_files" {
  for_each = fileset("${path.module}/static_files", "**/*")

  bucket       = aws_s3_bucket.bucket_1.id
  key          = each.key
  source       = "${path.module}/static_files/${each.key}"
  etag         = filemd5("${path.module}/static_files/${each.key}")
  content_type = lookup(
    local.mime_types,
    regex("\\.[^.]+$", each.key),
    "application/octet-stream"
  )
}

## task 4
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.bucket_1.id

  rule {
    id     = "manage-objects"
    status = "Enabled"

    filter {}  # Targets all objects in the bucket

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 101
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

## task 5
output "bucket_name" {
  value = aws_s3_bucket.bucket_1.id
}

output "example_key" {
  value = "ipsum.txt" 
}

##################################################################################
## use cli for pre-signed url  
## aws s3 presign s3://michaelcg-storage-bucket-123/ipsum.txt --expires-in 3600
##################################################################################

