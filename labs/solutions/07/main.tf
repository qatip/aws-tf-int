# Task 1
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "storage" {
  bucket = "REPLACE_WITH_UNIQUE_BUCKET_NAME"

  # Disposable lab bucket only: remove all versions during terraform destroy.
  force_destroy = true

  tags = {
    Name   = "Terraform storage lab"
    Course = "QATIPINT"
    Lab    = "07"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.storage.id
}

# Task 2
resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.storage.arn,
        "${aws_s3_bucket.storage.arn}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}

# Task 3
locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

resource "aws_s3_object" "upload_files" {
  for_each = fileset("${path.module}/static_files", "**/*")

  bucket      = aws_s3_bucket.storage.id
  key         = each.key
  source      = "${path.module}/static_files/${each.key}"
  source_hash = filemd5("${path.module}/static_files/${each.key}")

  content_type = lookup(
    local.mime_types,
    lower(try(regex("\\.[^.]+$", each.key), "")),
    "application/octet-stream"
  )

  depends_on = [
    aws_s3_bucket_versioning.storage,
    aws_s3_bucket_server_side_encryption_configuration.storage
  ]
}

# Task 4
resource "aws_s3_bucket_lifecycle_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  rule {
    id     = "archive-and-expire"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.storage]
}

# Task 5
output "object_uri" {
  value = "s3://${aws_s3_bucket.storage.id}/${aws_s3_object.upload_files["Teide.jpeg"].key}"
}

output "object_https_url" {
  value = "https://${aws_s3_bucket.storage.id}.s3.us-west-2.amazonaws.com/Teide.jpeg"
}
