output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.example.bucket
}

output "environment" {
  description = "The environment"
  value       = upper(var.environment)
}