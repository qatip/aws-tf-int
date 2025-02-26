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
  region    = each.value.region
  subnets   = [for k, v in var.subnets[each.key] : { name = k, cidr_block = v }]
}

module "sgs" {
  for_each = { for k, v in module.vpcs : k => v.vpc_details }
  source   = "./modules/sg"
  sg_name  = "${each.value.name}-sg"
  vpc_id   = each.value.id
}

resource "aws_vpc_peering_connection" "peer" {
  for_each = {
    peer1to2 = { local = "vpc1", remote = "vpc2" }
    peer2to1 = { local = "vpc2", remote = "vpc1" }
  }

  vpc_id      = module.vpcs[each.value.local].vpc_id
  peer_vpc_id = module.vpcs[each.value.remote].vpc_id
  auto_accept = true
}