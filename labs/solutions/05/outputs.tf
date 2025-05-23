output "s3_bucket_name" {
  value = aws_s3_bucket.lab_bucket.id
}

output "instance_id" {
  value = aws_instance.lab_instance.id
}

output "iam_role_name" {
  value = aws_iam_role.lab_role.name
}