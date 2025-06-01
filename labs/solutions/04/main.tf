provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}




module "vpc1" {
  source    = "./modules/vpc"
  vpc_name  = "vpc-01"
  cidr_block = "10.0.0.0/16"
}

module "vpc2" {
  source    = "./modules/vpc"
  vpc_name  = "vpc-02"
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = module.vpc1.vpc_id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "subnet-01"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = module.vpc2.vpc_id
  cidr_block = "10.1.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] 
  tags = {
    Name = "subnet-02"
  }
}