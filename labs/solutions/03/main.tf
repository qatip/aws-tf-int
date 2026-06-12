terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
#  assume_role {
#    role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/TerraformRole"
#  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "<unique_bucket_name>"
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

#data "aws_caller_identity" "current" {}
#
#output "terraform_identity" {
#  value = data.aws_caller_identity.current.arn
#}

