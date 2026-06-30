provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

data "aws_availability_zones" "east" {
  provider = aws.east
  state    = "available"
}

data "aws_availability_zones" "west" {
  provider = aws.west
  state    = "available"
}

module "vpc_east" {}

module "vpc_west" {}