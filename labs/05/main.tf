provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Lab05"
  }
}

resource "aws_iam_role" "lab_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  lifecycle {
    postcondition {
      condition     = self.name == var.iam_role_name
      error_message = "IAM Role name does not match the expected value."
    }
  }
}

resource "aws_instance" "lab_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.lab_profile.name

  tags = {
    Name = "Lab05-Instance"
  }
}

resource "aws_iam_instance_profile" "lab_profile" {
  name = "Lab05InstanceProfile"
  role = aws_iam_role.lab_role.name
}