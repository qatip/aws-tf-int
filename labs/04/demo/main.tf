terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpcs" {
  for_each = var.vpcs
  source    = "./modules/vpc"
  vpc_name  = each.value.name
  cidr_block = each.value.cidr_block
  subnets   = [for k, v in var.subnets[each.key] : { name = k, cidr_block = v }]
}

module "sgs" {
  for_each = { for k, v in module.vpcs : k => v.vpc_details }
  source   = "./modules/sg"
  sg_name  = "${each.value.name}-sg"
  vpc_id   = each.value.id
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = module.vpcs["vpc1"].vpc_details.id
  peer_vpc_id = module.vpcs["vpc2"].vpc_details.id
  auto_accept = true

  tags = {
    Name = "peer-vpc1-vpc2"
  }
}

