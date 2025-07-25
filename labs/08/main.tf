provider "aws" {
  region = "eu-west-2"
}
terraform {
  backend "s3" {
    bucket         = "{your state bucket}"   
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}
resource "aws_s3_bucket" "example" {
bucket = "jenkins-test-bucket-{yournamehere}"
acl    = "private"
}
