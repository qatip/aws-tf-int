provider "aws" {
  region = "us-east-1"
  alias  = "useast"
}

provider "aws" {
  region = "us-west-2"
  alias  = "uswest"
}

module "vpc_east" {
  source     = "./modules/vpc"
  providers  = {
    aws = aws.useast
  }
  vpc_name   = "vpc-east"
  cidr_block = "10.0.0.0/16"
}

module "vpc_west" {
  source     = "./modules/vpc"
  providers  = {
    aws = aws.uswest
  }
  vpc_name   = "vpc-west"
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "subnet_east" {
  provider   = aws.useast
  vpc_id     = module.vpc_east.vpc_id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-east"
  }
}

resource "aws_subnet" "subnet_west" {
  provider   = aws.uswest
  vpc_id     = module.vpc_west.vpc_id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "subnet-west"
  }
}
