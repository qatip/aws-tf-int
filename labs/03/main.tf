terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
#  assume_role {
#    role_arn = "arn:aws:iam::{change-me}:role/TerraformRole"
#    session_name = "qatipint-lab03"
#  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "{change-me}"
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

#data "aws_caller_identity" "current" {}
#
#output "terraform_identity" {
#  value = data.aws_caller_identity.current.arn
#}

