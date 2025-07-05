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

module "vpc_east" {
  source            = "./modules/vpc"
  providers         = { aws = aws.east }
  vpc_name          = "vpc-east"
  vpc_cidr          = var.vpc_east_cidr
  subnet_name       = "subnet-east"
  subnet_cidr       = var.subnet_east_cidr
  availability_zone = data.aws_availability_zones.east.names[0]
}

module "vpc_west" {
  source            = "./modules/vpc"
  providers         = { aws = aws.west }
  vpc_name          = "vpc-west"
  vpc_cidr          = var.vpc_west_cidr
  subnet_name       = "subnet-west"
  subnet_cidr       = var.subnet_west_cidr
  availability_zone = data.aws_availability_zones.west.names[0]
}