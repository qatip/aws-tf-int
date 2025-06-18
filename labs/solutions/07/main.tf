provider "aws" {
  region = "us-east-1"
}

locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

resource "aws_s3_bucket" "media_bucket" {
  bucket = "qatip-demo-static-mcg-001"  # Change to your unique bucket name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.media_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "secure_transport_policy" {
  bucket = aws_s3_bucket.media_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.media_bucket.arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.media_bucket.id

  rule {
    id     = "glacier-then-delete"
    status = "Enabled"

    filter {}  # Required, even if applying to all objects

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_object" "uploaded_files" {
  for_each = fileset("${path.module}/static_files", "**/*")

  bucket       = aws_s3_bucket.media_bucket.id
  key          = each.value
  source       = "${path.module}/static_files/${each.value}"
  etag         = filemd5("${path.module}/static_files/${each.value}")
  content_type = lookup(
    local.mime_types,
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
  )
}

# Optional: Data block for pre-sign URL generation (referenced for command)
data "aws_s3_object" "Teide" {
  bucket = aws_s3_bucket.media_bucket.id
  key    = "Teide.jpeg"
}

output "pre_signed_url_command_to_run" {
  value     = "aws s3 presign s3://${aws_s3_bucket.media_bucket.id}/Teide.jpeg --expires-in 3600"
}
