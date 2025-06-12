provider "aws" {
  region  = "us-east-1"


  assume_role {
    role_arn     = "arn:aws:iam::<Account_ID>:role/TerraformLimitedAccessRole"
    session_name = "terraform-session"
  }
}

resource "aws_instance" "validated_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    precondition {
      condition     = startswith(var.instance_type, "t2")
      error_message = "Only t2 instance types are allowed."
    }
  }

  tags = {
    Name = "ValidatedEC2"
  }
}

locals {
  actual_bucket_name = replace(var.bucket_name, "lab-bucket", "lab-bucket") # simulate a logic error replacing the bucket name as defined by variable.
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = local.actual_bucket_name
  
  
  lifecycle {
  precondition {
    condition     = can(regex("lab-bucket", var.bucket_name))
    error_message = "Bucket name must include 'lab-bucket'."
  }

  postcondition {
    condition     = can(regex("lab-bucket", self.bucket))
    # self.bucket is the actual value of the bucket argument after Terraform evaluates the resource
    error_message = "The actual bucket name must contain 'lab-bucket'."
  }
}
  tags = {
    Purpose = "Terraform Validation Lab"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.lab_bucket.bucket
}